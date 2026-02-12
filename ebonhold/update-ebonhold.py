#!/usr/bin/env python3

# Update Ebonhold - A script to update WoW Ebonhold game files by downloading the latest versions from the server if they are outdated.
# Keep last updated dates in cache ('$LAST_PATCH_FILE') to only download files that have been updated since the last patch.
#
# Usage: ./update-ebonhold.sh [OPTIONS]
#
# Author: Pumbaa
# Github: https://github.com/pumbaa666/
# Website: https://pumbaa.ch
#
# License: MIT License

import os
import sys
import json
import shutil
import argparse
import getpass
import requests
from pathlib import Path
from datetime import datetime, timedelta, timezone

# -----------------------
# Constants
# -----------------------

API_BASE = "https://api.project-ebonhold.com/api"
LOGIN_API = f"{API_BASE}/auth/login"
FILES_URL = f"{API_BASE}/launcher/public-files?type=required"
DOWNLOAD_API = f"{API_BASE}/launcher/download?file_ids="

DOWNLOAD_LOCATION = Path("./downloads")
CACHE_LOCATION = Path("./cache")
TOKEN_FILE = CACHE_LOCATION / "token.json"
LAST_PATCH_FILE = CACHE_LOCATION / "last-patch-date.json"

DOWNLOAD_LOCATION.mkdir(parents=True, exist_ok=True)
CACHE_LOCATION.mkdir(parents=True, exist_ok=True)

# -----------------------
# Logging
# -----------------------

def log_debug(msg):
    if ARGS.debug:
        print(f"[DEBUG] {msg}", file=sys.stderr)

def log_info(msg):
    print(f"[INFO] {msg}")

def log_warn(msg):
    print(f"[WARN] {msg}", file=sys.stderr)

def log_error(msg):
    print(f"[ERROR] {msg}", file=sys.stderr)

# -----------------------
# .env loader (simple KEY=VALUE parser)
# -----------------------

def load_env_file():
    env_path = Path(".env")
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())

# -----------------------
# Token management
# -----------------------

def get_token(email, password):
    response = requests.post(
        LOGIN_API,
        json={"username": email, "password": password},
        timeout=30,
    )

    if response.status_code != 200:
        log_error(f"Login failed: {response.text}")
        sys.exit(2)

    data = response.json()
    token = data.get("token")
    expires_in = data.get("expiresIn", 3600)

    if not token:
        log_error(f"Login failed with response: {response.text}")
        sys.exit(2)

    if not isinstance(expires_in, int):
        log_warn(f"Invalid expiresIn value: {expires_in}, defaulting to 3600")
        expires_in = 3600

    valid_until = (
        datetime.now(timezone.utc) + timedelta(seconds=expires_in)
    ).strftime("%Y-%m-%dT%H:%M:%SZ")

    TOKEN_FILE.write_text(
        json.dumps(
            {
                "token": token,
                "expires_in": expires_in,
                "valid_until": valid_until,
            }
        )
    )

    return token


def load_cached_token():
    if not TOKEN_FILE.exists():
        return None

    data = json.loads(TOKEN_FILE.read_text())
    token = data.get("token")
    valid_until = data.get("valid_until")

    if not token or not valid_until:
        return None

    now = datetime.now(timezone.utc)
    expiry = datetime.strptime(valid_until, "%Y-%m-%dT%H:%M:%SZ").replace(
        tzinfo=timezone.utc
    )

    if now >= expiry:
        return None

    return token

# -----------------------
# Download logic
# -----------------------

def download_file(session, token, file_id, filename):
    log_debug(f"Fetching download URL for '{filename}' (ID: {file_id})")

    response = session.get(
        f"{DOWNLOAD_API}{file_id}",
        headers={"Authorization": f"Bearer {token}"},
        timeout=30,
    )

    if response.status_code != 200:
        log_warn(f"Failed to fetch download info for {filename}")
        return False

    data = response.json()
    files = data.get("files", [])
    if not files:
        log_warn(f"No download URL found for {filename}")
        return False

    download_url = files[0].get("url")
    if not download_url:
        log_warn(f"No download URL found for {filename}")
        return False

    if ARGS.dry_run:
        log_info(f"Dry run: would download '{filename}' from {download_url}")
        return True

    target_path = DOWNLOAD_LOCATION / filename
    target_path.parent.mkdir(parents=True, exist_ok=True)

    log_info(f"Downloading '{filename}'")

    with session.get(download_url, stream=True, timeout=60) as r:
        if r.status_code != 200:
            log_warn(f"Download failed for {filename}")
            return False
        with open(target_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

    return True

# -----------------------
# Main
# -----------------------

def parse_args():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--username")
    parser.add_argument("--password")
    parser.add_argument("--game-location")
    parser.add_argument("-l", "--login", action="store_true")
    parser.add_argument("-f", "--force", action="store_true")
    parser.add_argument("-c", "--clear", action="store_true")
    parser.add_argument("-dr", "--dry-run", action="store_true")
    parser.add_argument("-d", "--debug", action="store_true")
    parser.add_argument("-h", "--help", action="help")
    return parser.parse_args()

load_env_file()
ARGS = parse_args()

email = (
    ARGS.username
    or os.environ.get("ACCOUNT_EMAIL")
)
password = (
    ARGS.password
    or os.environ.get("ACCOUNT_PASSWORD")
)

if not email:
    email = input("Enter your account email: ")

if not password:
    password = getpass.getpass("Enter your account password: ")

if not email or not password:
    log_error("ACCOUNT_EMAIL and ACCOUNT_PASSWORD must be set")
    sys.exit(1)

log_info("1. Logging in...")

if ARGS.login:
    token = get_token(email, password)
else:
    token = load_cached_token()
    if not token:
        log_info("No valid cached token found, logging in...")
        token = get_token(email, password)
    else:
        log_debug("Using cached token")

session = requests.Session()

log_info("2. Fetching required files list...")
response = session.get(
    FILES_URL,
    headers={"Authorization": f"Bearer {token}"},
    timeout=30,
)

if response.status_code != 200:
    log_error(f"Failed to fetch file list: {response.text}")
    sys.exit(3)

data = response.json()
files = data.get("files", [])

if not files:
    log_warn(f"No files found. Raw response: {response.text}")

server_latest = {f["name"]: f["updated_at"] for f in files}
name_to_id = {f["name"]: f["id"] for f in files}

log_info("3. Checking for updates...")

local_latest = {}
if LAST_PATCH_FILE.exists():
    local_latest = json.loads(LAST_PATCH_FILE.read_text())
else:
    log_info("No last patch file found, assuming all files outdated.")

log_info("4. Download outdated files...")

updated_files = {}

for filename, latest_date in server_latest.items():
    log_info(f"Checking '{filename}' (latest: {latest_date})")

    try:
        latest_ts = datetime.fromisoformat(
            latest_date.replace("Z", "+00:00")
        )
    except Exception:
        continue

    last_patch = local_latest.get(filename, "1970-01-01T00:00:00Z")
    try:
        last_ts = datetime.fromisoformat(
            last_patch.replace("Z", "+00:00")
        )
    except Exception:
        continue

    needs_download = (
        ARGS.force
        or (ARGS.game_location and not (Path(ARGS.game_location) / filename).exists())
        or latest_ts > last_ts
    )

    if needs_download:
        if download_file(session, token, name_to_id[filename], filename):
            updated_files[filename] = latest_date
    else:
        updated_files[filename] = latest_date

if ARGS.dry_run:
    log_info("Dry run mode: not saving patch data.")
    sys.exit(0)

log_info("5. Saving latest file update dates...")
LAST_PATCH_FILE.write_text(json.dumps(updated_files, indent=2))

if ARGS.game_location:
    game_path = Path(ARGS.game_location)
    log_info("6. Copying downloaded files to game directory...")

    for filename in updated_files:
        src = DOWNLOAD_LOCATION / filename
        if not src.exists():
            continue

        dest = game_path / filename
        dest.parent.mkdir(parents=True, exist_ok=True)

        if ARGS.clear:
            shutil.move(str(src), str(dest))
            log_debug(f"Moved '{filename}'")
        else:
            shutil.copy2(str(src), str(dest))
            log_debug(f"Copied '{filename}'")
else:
    log_info("No game location specified, skipping copy step.")

log_info("Update process completed.")
