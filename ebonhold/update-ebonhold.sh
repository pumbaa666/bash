#!/usr/bin/env bash
# set -euo pipefail

# Constats
DEBUG=${1:-"false"}

API_BASE="https://api.project-ebonhold.com/api"
LOGIN_API="${API_BASE}/auth/login"
FILES_URL="${API_BASE}/launcher/public-files?type=required"
DOWNLOAD_API="${API_BASE}/launcher/download?file_ids="

DOWNLOAD_LOCATION="./downloads"
mkdir -p "$DOWNLOAD_LOCATION"

# Format : JSON containing the JWT token and validity info
# { "token": "<TOKEN>", "valid_until": "2026-01-01T12:00:00Z" }
TOKEN_FILE="cache/token.json"

# Format : JSON containing the last patch date info of each file
# { "Wow.exe": "2026-01-01T12:00:00Z", "Patch-X.mpq": "2026-01-01T12:00:00Z" }
LAST_PATCH_FILE="cache/last-patch-date.json"

# Load / Check required environment variables
ACCOUNT_EMAIL="${ACCOUNT_EMAIL:-}"
ACCOUNT_PASSWORD="${ACCOUNT_PASSWORD:-}"
if [[ -f ".env" ]]; then
    source .env
fi
if [[ -z "$ACCOUNT_EMAIL" || -z "$ACCOUNT_PASSWORD" ]]; then
    echo "Error: ACCOUNT_EMAIL and ACCOUNT_PASSWORD environment variables must be set (or defined in .env file)" >&2
    exit 1
fi

# Helper functions
function log_info() {
    echo -e "[INFO] $1"
}

function log_warn() {
    echo -e "[WARN] $1" >&2
}

function log_debug() {
    [[ "$DEBUG" == "true" ]] && echo -e "[DEBUG] $1" >&2
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

function get_token() {
    token_response="$(
    curl -sS \
        -H "Content-Type: application/json" \
        -X POST "$LOGIN_API" \
        --data-binary "$(jq -nc \
        --arg u "$ACCOUNT_EMAIL" \
        --arg p "$ACCOUNT_PASSWORD" \
        '{username:$u,password:$p}')" \
    | jq -r '.'
    )"
    token=$(echo "$token_response" | jq -r '.token')
    token_expires_in=$(echo "$token_response" | jq -r '.expiresIn') # in seconds
    token_validity_date=$(date -d "+$token_expires_in seconds" -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"token\":\"$token\",\"expires_in\":$token_expires_in,\"valid_until\":\"$token_validity_date\"}" > "$TOKEN_FILE"
}

function download_file() {
    local file_id="$1"
    local filename="$2"
    log_info "Downloading file '$filename' (ID: $file_id)..."
    if [[ "$filename" == */* ]]; then
        local dir_path="${filename%/*}"
        mkdir -p "${DOWNLOAD_LOCATION}/${dir_path}"
    fi

    local download_response=$(curl -sS -H "Authorization: Bearer $TOKEN" "${DOWNLOAD_API}${file_id}")
    log_debug "Download raw response for file '$filename' (ID: $file_id): $download_response"
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
        log_warn "No download URL found for file '$filename' (ID: $file_id), skipping download..."
        return 1
    fi
    local file_path="${DOWNLOAD_LOCATION}/${filename}"
    rm -f "${file_path}"
    curl -sS -L "$download_url" -o "${file_path}"
}

# Main script logic
log_info "1. Logging in..."
if [[ -f "$TOKEN_FILE" ]]; then
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
else
    log_info "No cached token found, logging in..."
    get_token
fi

echo ""
log_info "2. Fetching required files list..."
file_list_response=$(curl -sS -H "Authorization: Bearer $TOKEN" "$FILES_URL")
log_debug "Files:"
file_list=$(echo "$file_list_response" | jq -r '.files[] | "[\(.id)] \(.name) (updated at: \(.updated_at))"')
log_debug "$file_list"

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
    if [[ -z "$latest_date" ]]; then
        log_warn "No latest date found for file '$filename', skipping..."
        continue
    fi
    last_patch_date="${local_latest_files[$filename]:-1970-01-01T00:00:00Z}"
    if [[ "$latest_date" > "$last_patch_date" ]]; then
        log_info "File '$filename' is outdated (latest: $latest_date, last patch: $last_patch_date), downloading..."
        download_file "${name_to_id_map[$filename]}" "$filename"
        if [[ $? -eq 0 ]]; then
            log_info "File '$filename' downloaded successfully"
            up_to_date_files["$filename"]="$latest_date"
        fi
    else
        log_debug "File '$filename' is up to date (latest: $latest_date, last patch: $last_patch_date), skipping..."
        up_to_date_files["$filename"]="$latest_date"
    fi
done

echo ""
log_info "5. Saving latest file update dates..."
server_latest_files_json=""
for filename in "${!up_to_date_files[@]}"; do
    updated_at="${up_to_date_files[$filename]}"
    server_latest_files_json+=$(jq -n --arg name "$filename" --arg date "$updated_at" '{name: $name, updated_at: $date}')
done
echo "$server_latest_files_json" | jq -s 'reduce .[] as $item ({}; .[$item.name] = $item.updated_at)' > "$LAST_PATCH_FILE"
log_debug "Updated last patch date file content:\n$(cat "$LAST_PATCH_FILE")"