#!/usr/bin/env bash
set -euo pipefail

# Constants
DEBUG=false
DRY_RUN=false
FORCE_LOGIN=false
FORCE_DOWNLOAD=false

API_BASE="https://api.project-ebonhold.com/api"
LOGIN_API="${API_BASE}/auth/login"
FILES_URL="${API_BASE}/launcher/public-files?type=required"
DOWNLOAD_API="${API_BASE}/launcher/download?file_ids="

DOWNLOAD_LOCATION="./downloads"
CACHE_LOCATION="./cache"
GAME_LOCATION="./wow"
mkdir -p "$DOWNLOAD_LOCATION"
mkdir -p "$CACHE_LOCATION"

# Format : JSON containing the JWT token and validity info
# { "token": "<TOKEN>", "valid_until": "2026-01-01T12:00:00Z" }
TOKEN_FILE="$CACHE_LOCATION/token.json"
# Format : JSON containing the last patch date info of each file
# { "Wow.exe": "2026-01-01T12:00:00Z", "Patch-X.mpq": "2026-01-01T12:00:00Z", ... }
LAST_PATCH_FILE="$CACHE_LOCATION/last-patch-date.json"

# Load environment variables from .env file if it exists
if [[ -f ".env" ]]; then
    source .env
fi

# Reading order : 1. Command-line arguments 2. Inline Environment variables 3. .env file Environment variables Fallback to Interactive input if not set in any of the previous sources
ACCOUNT_EMAIL="${ACCOUNT_EMAIL:-}"
ACCOUNT_PASSWORD="${ACCOUNT_PASSWORD:-}"

# Logging functions
function log_debug() {
    if [[ $DEBUG == true ]]; then
        echo -e "[DEBUG] $1" >&2
    fi
}

function log_info() {
    echo -e "[INFO] $1"
}

function log_warn() {
    echo -e "[WARN] $1" >&2
}

function log_error() {
    echo -e "[ERROR] $1" >&2
}

function help() {
    echo "Update Ebonhold - A script to update Ebonhold game files by downloading the latest versions from the server if they are outdated compared to the last patch date."
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --username=EMAIL       Account email (can also be set via ACCOUNT_EMAIL environment variable or .env file)"
    echo "  --password=PASSWORD    Account password (can also be set via ACCOUNT_PASSWORD environment variable or .env file)"
    echo "                         If one of them are not provided, the script will prompt for them interactively"
    echo "  --login, -l            Force login and refresh token (useful if you want to use a different account or refresh the token manually)"
    echo "                         Token is located at '$TOKEN_FILE'"
    echo "  --force, -f            Force download of all files, even if they are up-to-date"
    echo "                         Files are downloaded to '$DOWNLOAD_LOCATION' and then copied to game directory '$GAME_LOCATION'"
    echo "  --dry-run, -dr         Don't download or copy any file, just print what would be done"
    echo "  --debug, -d            Print more debug messages"
    echo "  --help, -h             Display this help message"
    echo ""
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --username=*)       ACCOUNT_EMAIL="${1#*=}";;
        --password=*)       ACCOUNT_PASSWORD="${1#*=}";;
        -l|--login)         FORCE_LOGIN=true;;
        -f|--force)         FORCE_DOWNLOAD=true;;
        -dr|--dry-run)      DRY_RUN=true;;
        -d|--debug)         DEBUG=true;;
        -h|--help)          help;;
        *) echo "Unknown parameter: $1"; help;;
    esac
    shift
done

# Check required credentials and prompt interactively if not set
if [[ -z "$ACCOUNT_EMAIL" ]]; then
    read -p "Enter your account email: " ACCOUNT_EMAIL
fi
if [[ -z "$ACCOUNT_PASSWORD" ]]; then
    read -s -p "Enter your account password: " ACCOUNT_PASSWORD
    echo ""
fi
if [[ -z "$ACCOUNT_EMAIL" || -z "$ACCOUNT_PASSWORD" ]]; then
    echo "Error: ACCOUNT_EMAIL and ACCOUNT_PASSWORD must be set (interactively, in environment variables or defined in .env file)" >&2
    exit 1
fi

# Helper functions

# Fetch a new token from the login API and save it to the cache file with its expiration info
function get_token() {
    local token_response="$(curl -sS \
        -H "Content-Type: application/json" \
        -X POST "$LOGIN_API" \
        --data-binary "$(jq -nc \
        --arg u "$ACCOUNT_EMAIL" \
        --arg p "$ACCOUNT_PASSWORD" \
        '{username:$u,password:$p}')" \
    )"
    TOKEN=$(echo "$token_response" | jq -r '.token')
    local token_expires_in=$(echo "$token_response" | jq -r '.expiresIn') # in seconds
    if [[ ! "$token_expires_in" =~ ^[0-9]+$ ]]; then
        log_warn "Invalid token expiration time received: $token_expires_in"
        token_expires_in=3600 # Default to 1 hour if invalid
    fi
    local token_validity_date=$(date -d "+$token_expires_in seconds" -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"token\":\"$TOKEN\",\"expires_in\":$token_expires_in,\"valid_until\":\"$token_validity_date\"}" > "$TOKEN_FILE"
}

# Download a file by its ID and save it to the download location with the correct filename
# Create directory structure if needed
function download_file() {
    local file_id="$1"
    local filename="$2"
    log_debug "\tFetching file URL for '$filename' (ID: $file_id)..."
    if [[ "$filename" == */* ]]; then
        local dir_path="${filename%/*}"
        mkdir -p "${DOWNLOAD_LOCATION}/${dir_path}"
    fi

    local download_response=$(curl -sS -H "Authorization: Bearer $TOKEN" "${DOWNLOAD_API}${file_id}")
    log_debug "\tDownload raw response for file '$filename' (ID: $file_id): $download_response"
    # Response format :
    # {
    #     "success": true,
    #     "files": [
    #         {
    #             "file_id": 47,
    #             "url": "<URL>",
    #             "filename": "<filename>"
    #         }
    #     ]
    # }

    # Really download
    local download_url=$(echo "$download_response" | jq -r '.files[0].url // empty')
    if [[ -z "$download_url" ]]; then
        log_warn "\tNo download URL found for file '$filename' (ID: $file_id), skipping download..."
        return 1
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "\tDry run mode: would download file '$filename' (ID: $file_id) from URL: $download_url"
        return 0
    fi
    log_info "\tDownloading file '$filename'..."
    local file_path="${DOWNLOAD_LOCATION}/${filename}"
    rm -f "${file_path}"
    curl -f -sS -L "$download_url" -o "${file_path}"
    if [[ $? -ne 0 ]]; then
        log_warn "\tFailed to download file '$filename' (ID: $file_id) from URL: $download_url"
        return 1
    fi
}

# For debugging purposes, print the content of an associative array in a readable format
function print_array() {
    local key value name;
    for name in "$@";
    do
        echo "${name}";
        echo "(";
        eval "for key in \"\${!${name}[@]}\"; do
                value=\"\${${name}[\$key]}\"
                echo \"  [\$key] => \\\"\$value\\\"\"
              done";
        echo ")";
    done
}

# Main script logic
log_info "1. Logging in..."
if [[ $FORCE_LOGIN == true || ! -f "$TOKEN_FILE" ]]; then
    log_info "No cached token found, logging in..."
    get_token
else
    log_debug "Cached token found, checking validity..."
    token_data="$(<"$TOKEN_FILE")"
    TOKEN="$(echo "$token_data" | jq -r '.token')"
    token_valid_until="$(echo "$token_data" | jq -r '.valid_until')"
    current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if [[ "$current_time" > "$token_valid_until" ]]; then
        log_info "Cached token has expired (valid until $token_valid_until), logging in again..."
        get_token
    else
        log_debug "Token is still valid, using cached token"
    fi
fi
if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
    log_error "Login failed: $TOKEN"
    exit 2
fi

echo ""
log_info "2. Fetching required files list..."
file_list_response=$(curl -sS -H "Authorization: Bearer $TOKEN" "$FILES_URL")
file_list=$(echo "$file_list_response" | jq -r '.files[] | "\t[\(.id)] \(.name) (updated at: \(.updated_at))"')
log_debug "\n$file_list"

# Maps of filename to last updated date and filename to file ID
declare -A server_latest_files
declare -A name_to_id_map
while IFS= read -r file_info; do
    filename=$(echo "$file_info" | jq -r '.name')
    file_id=$(echo "$file_info" | jq -r '.id')
    updated_at=$(echo "$file_info" | jq -r '.updated_at')
    server_latest_files["$filename"]="$updated_at"
    name_to_id_map["$filename"]="$file_id"
done < <(echo "$file_list_response" | jq -c '.files[]')

echo ""
log_info "3. Checking for updates..."
declare -A local_latest_files
if [[ -f "$LAST_PATCH_FILE" ]]; then
    log_debug "Last patch date file found, loading data..."
    while IFS= read -r line; do
        key=$(echo "$line" | jq -r '.key')
        value=$(echo "$line" | jq -r '.value')
        local_latest_files["$key"]="$value"
    done < <(jq -c 'to_entries[]' "$LAST_PATCH_FILE")
else
    log_info "No last patch date file found, assuming all files are outdated..."
fi

echo ""
log_info "4. Download outdated files..."
declare -A up_to_date_files
for filename in "${!server_latest_files[@]}"; do
    latest_date="${server_latest_files[$filename]}"
    echo ""
    log_info "Checking file '$filename' (latest update: $latest_date)..."

    if [[ -z "$latest_date" ]]; then
        log_warn "No latest date found for file '$filename', skipping..."
        continue
    fi
    latest_date_ts=$(date -d "$latest_date" +%s)

    last_patch_date="${local_latest_files[$filename]:-1970-01-01T00:00:00Z}"
    last_patch_date_ts=$(date -d "$last_patch_date" +%s)
    if [[ $FORCE_DOWNLOAD == true || ! -f "$GAME_LOCATION/$filename" || $latest_date_ts -gt $last_patch_date_ts ]]; then
        log_debug "File '$filename' is outdated (latest: $latest_date, last patch: $last_patch_date), downloading..."
        download_file "${name_to_id_map[$filename]}" "$filename"
        if [[ $? -eq 0 ]]; then
            log_info "\tSuccess"
            up_to_date_files["$filename"]="$latest_date"
        fi
    else
        log_debug "\tUp to date"
        up_to_date_files["$filename"]="$latest_date"
    fi
done

echo ""
log_info "5. Saving latest file update dates..."
if [[ $DRY_RUN == true ]]; then
    log_info "Dry run mode: would save latest file update dates to '$LAST_PATCH_FILE'. Exiting"
    exit 0
fi

server_latest_files_json=""
for filename in "${!up_to_date_files[@]}"; do
    updated_at="${up_to_date_files[$filename]}"
    server_latest_files_json+=$(jq -n --arg name "$filename" --arg date "$updated_at" '{name: $name, updated_at: $date}')
done
echo "$server_latest_files_json" | jq -s 'reduce .[] as $item ({}; .[$item.name] = $item.updated_at)' > "$LAST_PATCH_FILE"
log_debug "Updated last patch date file content:\n$(cat "$LAST_PATCH_FILE")"

echo ""
log_info "6. Copying downloaded files to game directory..."
for filename in "${!up_to_date_files[@]}"; do
    if [[ -f "$DOWNLOAD_LOCATION/$filename" ]]; then
        dest_path="$GAME_LOCATION/$filename"
        dest_dir=$(dirname "$dest_path")
        mkdir -p "$dest_dir"
        cp -f "$DOWNLOAD_LOCATION/$filename" "$dest_path"
        log_debug "Copied '$filename' to game directory"
    fi
done

echo ""
log_info "Update process completed."