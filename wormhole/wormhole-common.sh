#!/bin/bash

# Common functions and variables for wormhole scripts

# Just to check if this script has already been sourced
function wormhole_common_init() {
    true
}

# Log functions
function log_debug() {
    echo -e "[DEBUG] $*"
}

function log_info() {
    echo -e "[INFO] $*"
}

function log_error() {
    echo -e "[ERROR] $*" >&2
}

# Check dependencies
XCLIP_AVAILABLE=true
ZENITY_AVAILABLE=true
if ! command -v "wormhole" &> /dev/null; then
    log_error "Wormhole is not installed. Please install with `sudo apt install magic-wormhole` and try again"
    if [[ "${ZENITY_AVAILABLE}" == "true" ]]; then
        zenity --error --title="Wormhole" --text="Wormhole is not installed. Please install with `sudo apt install magic-wormhole` and try again"
    fi
    exit 1
fi

if ! command -v "zenity" &> /dev/null; then
    log_info "Zenity is not installed. You can install with `sudo apt install zenity` to enable popup messages."
    ZENITY_AVAILABLE=false
fi

if ! command -v "xclip" &> /dev/null; then
    log_info "Xclip is not installed. You can install with `sudo apt install xclip` to enable clipboard support."
    XCLIP_AVAILABLE=false
fi
