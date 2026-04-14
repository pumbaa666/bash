#!/usr/bin/env bash
#
# ==============================================================
# YouTube Playlist Downloader
# ==============================================================
# Downloads all videos from a YouTube playlist using yt-dlp.
#
# Features:
#   - Download as MP4 (video) or MP3 (audio)
#   - Selectable quality
#   - Clean, colored output
#   - Automatic dependency checks
#   - Organized directory structure
#
# Usage:
#   ./yt-playlist-downloader.sh -u <PLAYLIST_URL> [options]
#
# Options:
#   -u, --url       Playlist URL (required)
#   -f, --format    Format: mp4 (default) or mp3
#   -q, --quality   240p, 360p, 480p, 720p (default), 1024p, 4k
#   -o, --output    Output directory (default: ./downloads)
#   -h, --help      Show help
#
# Examples:
#   ./script.sh -u "https://youtube.com/playlist?list=XXXX"
#   ./script.sh -u "<URL>" -f mp3
#   ./script.sh -u "<URL>" -f mp4 -q 4k
# ==============================================================

set -euo pipefail
IFS=$'\n\t'

# -------------------------------
# Colors
# -------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# -------------------------------
# Default Values
# -------------------------------
FORMAT="mp4"
QUALITY="720p"
OUTPUT_DIR="./downloads"
PLAYLIST_URL=""

# -------------------------------
# Logging Functions
# -------------------------------
function log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

function log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# -------------------------------
# Help Message
# -------------------------------
function show_help() {
    sed -n '2,50p' "$0"
    exit 0
}

# -------------------------------
# Dependency Checks
# -------------------------------
function check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v yt-dlp &>/dev/null; then
        log_error "yt-dlp is not installed. Install with: pip install -U yt-dlp"
    fi

    if ! command -v ffmpeg &>/dev/null; then
        log_error "ffmpeg is not installed."
    fi

    log_success "All dependencies are installed."
}

# -------------------------------
# Argument Parsing
# -------------------------------
function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--url)
                PLAYLIST_URL="$2"
                shift 2
                ;;
            -f|--format)
                FORMAT="$2"
                shift 2
                ;;
            -q|--quality)
                QUALITY="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                ;;
        esac
    done

    [[ -z "$PLAYLIST_URL" ]] && log_error "Playlist URL is required. Use -u."
    log_info "Playlist URL: $PLAYLIST_URL"
}

# -------------------------------
# Validate Inputs
# -------------------------------
function validate_inputs() {
    if [[ "$PLAYLIST_URL" != *"list="* ]]; then
        echo -e "\033[1;33m[WARNING]\033[0m The URL may not reference a playlist. Ensure it contains ${RED}list=${NC}."
        echo "Ensure the URL is quoted if it contains ${RED}'&'${NC}."
    fi

    case "$FORMAT" in
        mp4|mp3) ;;
        *)
            log_error "Invalid format: $FORMAT (mp4 or mp3 allowed)"
            ;;
    esac

    case "$QUALITY" in
        240p|360p|480p|720p|1024p|4k) ;;
        *)
            log_error "Invalid quality: $QUALITY"
            ;;
    esac
}

# -------------------------------
# Convert Quality to Height
# -------------------------------
function quality_to_height() {
    case "$QUALITY" in
        240p) echo 240 ;;
        360p) echo 360 ;;
        480p) echo 480 ;;
        720p) echo 720 ;;
        1024p) echo 1024 ;;
        4k) echo 2160 ;;
    esac
}

# -------------------------------
# Download Function
# -------------------------------
function download_playlist() {
    local height
    height=$(quality_to_height)

    mkdir -p "$OUTPUT_DIR"

    log_info "Starting download..."
    log_info "URL: $PLAYLIST_URL"
    log_info "Format: $FORMAT"
    log_info "Quality: $QUALITY"
    log_info "Output: $OUTPUT_DIR"

    if [[ "$FORMAT" == "mp3" ]]; then
        yt-dlp \
            --yes-playlist \
            --extract-audio \
            --audio-format mp3 \
            --audio-quality 0 \
            --embed-metadata \
            --embed-thumbnail \
            --add-metadata \
            -o "${OUTPUT_DIR}/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" \
            "$PLAYLIST_URL"
    else
        yt-dlp \
            --yes-playlist \
            -f "bestvideo[height<=${height}][ext=mp4]+bestaudio[ext=m4a]/best[height<=${height}][ext=mp4]" \
            --merge-output-format mp4 \
            --embed-metadata \
            --embed-thumbnail \
            --add-metadata \
            -o "${OUTPUT_DIR}/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" \
            "$PLAYLIST_URL"
    fi

    log_success "Download completed successfully."
}

# -------------------------------
# Main
# -------------------------------
function main() {
    parse_arguments "$@"
    validate_inputs
    check_dependencies
    download_playlist
}

main "$@"
