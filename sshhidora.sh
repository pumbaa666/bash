#!/bin/bash

# PARAMETERS
ENV_FILE_PATH="$(dirname "$0")/sshhidora.env"

# ENVIRONMENT VARIABLES
HIDORA_USER_ID=""
HIDORA_SSH_GATE_URL=""
HIDORA_SSH_PORT=""

# GLOBAL VARIABLES
HIDORA_MACHINE_ID=""
HIDORA_MACHINE_NAME=""
MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE=""
XCLIP_PROGRAM=""
SSH_PROGRAM=""

# TEXT COLORS
CYAN='\033[0;36m'
BG_CYAN='\033[46m'
RESET='\033[0m'

function usage() {
    echo "Usage: $0 HIDORA_MACHINE_ID (Optional) [OPTIONS]"
    echo ""
    echo "Connect with SSH to an Hidora machine."
    echo "If no Machine ID is provided as parameters, reads it from the clipboard."
    echo "Requires the following programs to run : xclip, ssh (or better : sshrc)"
    echo ""
    echo "Options:"
    echo "  -h,  --help   : Show this help message"
    exit 0
}

# Check that xclip and sshrc (or ssh) is installed
function checkRequiredPrograms() {
    XCLIP_PROGRAM="$(which xclip)"
    if [[ -z "${XCLIP_PROGRAM}" ]] ; then
        echo -e "[WARN] xclip is not installed, the programm won't be able to read from clipboard. Use parameters instead"
        echo -e "On Debian/Ubuntu, you can install it with:\n    sudo apt install xclip"
    fi

    SSH_PROGRAM="$(which sshrc)"
    if [[ ! -z "${SSH_PROGRAM}" ]] ; then
        return 0
    fi
    echo "[WARN] sshrc is not installed. Using ssh."

    SSH_PROGRAM="$(which ssh)"
    if [[ ! -z "${SSH_PROGRAM}" ]] ; then
        return 0
    fi
    echo -e "[ERROR] sshrc nor ssh are installed. Please install one of them to use this script." >&2
    echo -e "" >&2 # TODO: Provide installation instructions for ssh/sshrc.
    exit 1
}

# Load parameters
# This function loads the HIDORA_MACHINE_ID from the command line argument or clipboard if not provided.
function loadParameters() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help)  usage ;;
            -*)         echo "Unknown option: $1" ; usage ;;
            *)          HIDORA_MACHINE_ID="$1" ;;
        esac
        shift
    done

    if [[ ! -z "${HIDORA_MACHINE_ID}" ]]; then
        return 0
    fi

    # Load clipboard value into HIDORA_MACHINE_ID
    if [[ ! -z "${XCLIP_PROGRAM}" ]]; then
        HIDORA_MACHINE_ID=$(xclip -o -selection clipboard)
    fi

    # Check if HIDORA_MACHINE_ID is set and is a number
    if [[ -z "${HIDORA_MACHINE_ID}" ]]; then
        echo "HIDORA_MACHINE_ID is not set. Please provide it as an argument or copy it to the clipboard (needs xclip)."
        exit 2
    fi
    if ! [[ "${HIDORA_MACHINE_ID}" =~ ^[0-9]+$ ]]; then
        echo "HIDORA_MACHINE_ID must be a number. Please provide a valid ID."
        exit 2
    fi
}

# Loads environment variables from .env file or system env.
function loadEnvironmentVariables() {
    if [ -f "${ENV_FILE_PATH}" ]; then
        set -o allexport
        source "${ENV_FILE_PATH}"
        set +o allexport
    else
        echo "[WARN] .env file not found at ${ENV_FILE_PATH}. Proceeding with system env vars."
    fi

    if [[ -z "${HIDORA_USER_ID}" || -z "${HIDORA_SSH_GATE_URL}" || -z "${HIDORA_SSH_PORT}" ]] ; then
        echo "[ERROR] HIDORA_USER_ID or HIDORA_SSH_GATE_URL or HIDORA_SSH_PORT is not set. Exiting." >&2
        exit 1
    fi
}

# Find machine name from the correspondence array
function getMachineNameFromId() {
    # No correspondence table, so no name
    if [[ -z "${MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE}" ]] ; then
        return 0
    fi

    # Use comma as separator
    local pairs=()
    IFS=',' read -ra pairs <<< "${MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE}"
    
    for pair in "${pairs[@]}"; do
        # Use colon as separator
        IFS=':' read -ra id_name <<< "$pair"
        local environment_id="${id_name[0]}"
        local environment_name="${id_name[1]}"
        local container_name="${id_name[2]}"
        
        if [[ "${environment_id}" == "${HIDORA_MACHINE_ID}" ]]; then
            HIDORA_MACHINE_NAME=" [${BG_CYAN}${environment_name}${RESET}] ${CYAN}${container_name}${RESET}"
            return
        fi
    done
}

function sshToHidora() {
    local ssh_command="${SSH_PROGRAM} ${HIDORA_MACHINE_ID}-${HIDORA_USER_ID}@${HIDORA_SSH_GATE_URL} -p ${HIDORA_SSH_PORT}"
    echo -e "Connecting to Hidora machine ID: ${CYAN}${HIDORA_MACHINE_ID}${RESET}${HIDORA_MACHINE_NAME}"
    echo -e "${ssh_command}"
    ${ssh_command}
}

function main() {
    checkRequiredPrograms
    loadParameters "$@"
    loadEnvironmentVariables
    getMachineNameFromId
    sshToHidora
}

main "$@"