#!/bin/bash

# This script will send multiple files via `wormhole` in parallel
# and show a popup with their PIDs and one-time passwords.
# It then ask the user which data to copy to clipboard.
#
# Wormhole is a secure p2p file transfer tool.
# https://github.com/magic-wormhole/magic-wormhole
#
# This script is intended to be run from a file manager as a context menu action.
# To set it up, copy or symlink this script into the file manager scripts directory.
# (e.g. for Nautilus : `ln -s wormhole-send.sh ~/.local/share/nautilus/scripts/'Wormhole Send'`).
# Then restart your file manager (e.g. `nautilus -q`).
#
# Dependencies: 
# - `wormhole` to send the files via p2p (required) : `sudo apt install magic-wormhole`
# - `zenity` to show popups (optional) : `sudo apt install zenity`
# - `xclip` to access clipboard (optional) : `sudo apt install xclip`
# - `grep`, `awk`, `tail`, `uuidgen` (standard Unix utilities)
#
# Usage: ./wormhole-send.sh file1 file2 file3 ...
#
# Exit status:
# 0 - Success
# 1 - Wormhole not installed
# 2 - No OTPs found
#
# Author: Loic Correvon

TMP_DIR="/tmp/wormhole/"
mkdir -p "${TMP_DIR}"
RESULTS="${TMP_DIR}/wormhole-results_$(uuidgen).txt"
touch "${RESULTS}"

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
    log_error "Wormhole is not installed. Please install with \`sudo apt install magic-wormhole\` and try again"
    exit 1
fi

if ! command -v "zenity" &> /dev/null; then
    log_info "Zenity is not installed. You can install with \`sudo apt install zenity\` to enable popup messages."
    log_info "The program still works, but no popup will be shown. Prints the whole \`wormhole receive <OTP>\` and copy them into clipboard."
    ZENITY_AVAILABLE=false
fi

if ! command -v "xclip" &> /dev/null; then
    log_info "Xclip is not installed. You can install with \`sudo apt install xclip\` to enable clipboard support."
    log_info "The program still works, but no clipboard access will be available. Prints the whole \`wormhole receive <OTP>\` into stdout."
    XCLIP_AVAILABLE=false
fi

# Send each file in the background and capture its OTP via a temporary log file
# Wormhole outputs the OTP to stdout, so we redirect it to a log file for each file.
# Then we read the log file to extract the OTP.
log_debug "Starting wormhole send for $# files."
for FILE in "$@"; do
(
    if [[ ! -f "${FILE}" ]]; then
        log_debug "  Skipping non-file: ${FILE}"
        continue
    fi
    LOGFILE="${TMP_DIR}/$(basename "${FILE}").log"
    wormhole send "${FILE}" >"${LOGFILE}" 2>&1 &
    PID=$!
    log_debug "  Sending file: ${FILE}, log: ${LOGFILE} (PID: ${PID})"

    # Wait until the OTP (One-Time Password) line appears in the log
    OTP_LINE=$(tail -n0 -F "${LOGFILE}" | grep -m1 "wormhole receive")
    OTP=$(echo "${OTP_LINE}" | grep -oE "wormhole receive [A-Za-z0-9-]+" | awk '{print $3}')

    if [ -n "$OTP" ]; then
        echo "${FILE} ( PID ${PID} ) → ${OTP}" >> "${RESULTS}"
    else
        echo "${FILE} ( PID ${PID} ) → (no OTP found)" >> "${RESULTS}"
    fi
) &
done
log_debug "All wormhole send processes started in the background."

# Wait for all background OTP extraction processes to finish
wait
log_debug "All OTPs extracted."

# Show a popup with the results
if [[ ! -s "${RESULTS}" ]]; then
    log_error "No OTPs were found."
    [[ "${ZENITY_AVAILABLE}" == "true" ]] && zenity --error --title="Wormhole" --text="No OTPs were found."
    exit 2
fi

if [[ "${ZENITY_AVAILABLE}" == "true" ]]; then
    response=$(
        zenity --question \
        --title="Wormhole" \
        --width=600 \
        --text="$(cat "${RESULTS}")" \
        --ok-label="Copy commands" \
        --extra-button="Copy OTPs" \
        --extra-button="Copy PIDs" \
        --extra-button="Copy all" \
        --cancel-label="Exit"
    )
    response_status=$?
else
    # If Zenity is not available (to show the popup), set response to default (OK), to copy commands
    response=""
    response_status=0
fi

# Check the user's response and copy the requested data to clipboard
COPIED_TEXT=""
[[ "${XCLIP_AVAILABLE}" == "true" ]] && COPIED_TEXT="Copied to clipboard :\n"
if (( response_status == 0 )); then
    # Copy Commands (OK button)
    [[ "${XCLIP_AVAILABLE}" == "true" ]] && xclip -selection clipboard <<< "$(awk '{print "wormhole receive " $7}' "${RESULTS}")"
    log_debug "${COPIED_TEXT}$(awk '{print "\twormhole receive " $7}' "${RESULTS}")"
else
    # Another button
    case "${response}" in
        "Copy OTPs")
            [[ "${XCLIP_AVAILABLE}" == "true" ]] && xclip -selection clipboard <<< "$(awk '{print $7}' "${RESULTS}")"
            log_debug "${COPIED_TEXT}$(awk '{print "\t" $7}' "${RESULTS}")"
            ;;
        "Copy PIDs")
            [[ "${XCLIP_AVAILABLE}" == "true" ]] && xclip -selection clipboard <<< "$(awk '{print $4}' "${RESULTS}")"
            log_debug "${COPIED_TEXT}$(awk '{print "\t" $4}' "${RESULTS}")"
            ;;
        "Copy all")
            [[ "${XCLIP_AVAILABLE}" == "true" ]] && xclip -selection clipboard <<< "$(cat "${RESULTS}")"
            log_debug "${COPIED_TEXT}$(cat "${RESULTS}")"
            ;;
        *)
            # Cancel button
            exit 0
            ;;
    esac
fi

# Leave wormhole processes running — user must share OTPs manually.
log_debug "Done"
log_debug "Wormhole processes are still running in the background until the recipient receives the files"
exit 0
