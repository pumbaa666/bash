#!/bin/bash

# This script will ask for one or more wormhole otps and receive the files.
#
# Wormhole is a secure p2p file transfer tool.
# https://github.com/magic-wormhole/magic-wormhole
#
# This script is intended to be run from a file manager as a context menu action.
# To set it up, copy or symlink this script into the file manager scripts directory.
# (e.g. for Nautilus : `ln -s wormhole-receive.sh ~/.local/share/nautilus/scripts/'Wormhole Receive'`).
# Then restart your file manager (e.g. `nautilus -q`).
#
# Dependencies:
# - `wormhole` to receive the files via p2p (required) : `sudo apt install magic-wormhole`
# - `zenity` to show popups (optional) : `sudo apt install zenity`
# - `xclip` to access clipboard (optional) : `sudo apt install xclip`
#
# Usage: ./wormhole-receive.sh

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")" # Cannot use `dirname "${BASH_SOURCE[0]}` when this script is launched via a symlink
if ! declare -F wormhole_common_init > /dev/null; then
    source "${SCRIPT_DIR}/wormhole-common.sh" || { echo "Failed to source common.sh script. Aborting."; exit 1; }
fi

# Check if the clipboard contains some Wormhole OTP
otps=""
if [[ "${XCLIP_AVAILABLE}" == "true" ]]; then
    log_debug "Checking clipboard for Wormhole otps."
    readonly otp_regex="([0-9]\-[a-zA-Z]+\-[a-zA-Z]+)"
    clipboard_content=$(xclip -o -selection clipboard 2>/dev/null || echo "")
    while [[ $clipboard_content =~ $otp_regex ]]; do
        match="${BASH_REMATCH[1]} "
        match_length=${#match}
        log_debug "  Found OTP in clipboard: ${match}"
        otps+="${match} "
        clipboard_content="${clipboard_content:match_length}"
    done
fi

# Ask for otps
if [[ -z "${otps}" ]]; then
    log_debug "No OTP found in clipboard, asking user for input."
    if [[ "${ZENITY_AVAILABLE}" == "true" ]]; then
        otps=$(zenity --entry --title="Wormhole Receive" --text="Enter one or more Wormhole otps (separated by space, tab or new line):" --width=400)
    else
        echo "Enter one or more Wormhole otps (separated by space, tab or new line), then press Ctrl+D:"
        otps=$(cat)
    fi
fi

if [ -z "${otps}" ]; then
    log_debug "No OTP entered. Exiting."
    exit 0
fi

# Read the otps into an array, splitting by space, tab, or newline
read -r -a otp_array <<< "${otps}"

log_debug "Starting wormhole receive for ${#otp_array[@]} otps."
for otp in "${otp_array[@]}"; do
(
    log_info "Receiving with OTP: ${otp}"
    echo "Y" | wormhole receive "${otp}"
) &
done

# Wait for all background processes to finish
log_debug "All transfers attempted."
wait

log_debug "All transfers completed."
[[ "${ZENITY_AVAILABLE}" == "true" ]] && zenity --info --title="Wormhole" --text="All transfers completed."

exit 0
