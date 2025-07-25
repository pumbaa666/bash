#!/bin/bash

# PARAMETERS
ENV_FILE_PATH="$(dirname "$0")/sshhidora.env"
MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE="" # TODO 2D array of id's matching container name

# ENVIRONMENT VARIABLES
HIDORA_USER_ID=""
HIDORA_SSH_GATE_URL=""
HIDORA_SSH_PORT=""

# GLOBAL VARIABLES
HIDORA_MACHINE_ID=""
HIDORA_MACHINE_NAME=" (TODO)"
SSH_PROGRAM=""

usage() {
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
checkRequiredPrograms() {
    if ! command -v xclip &> /dev/null; then
        echo "[ERROR] xclip is not installed. Please install it to use this script." >&2
        echo -e "On Debian/Ubuntu, you can install it with:\n    sudo apt install xclip" >&2
        exit 1
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
    echo "[ERROR] sshrc nor ssh are installed. Please install one of them to use this script." >&2
    echo -e "" >&2 # TODO: Provide installation instructions for sshrc.
    exit 1
}

# Load parameters
# This function loads the HIDORA_MACHINE_ID from the command line argument or clipboard if not provided.
loadParameters() {
    # TODO fix. It works when using "sshhidora.sh MACHINE_ID --help", but not with "sshhidora.sh --help MACHINE_ID"
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help)  usage;;
        esac
        shift
    done

    if [[ ! -z "$1" ]]; then
        HIDORA_MACHINE_ID="$1"
        return 0
    fi

    HIDORA_MACHINE_ID=$(xclip -o -selection clipboard)
}

# Loads environment variables from .env file or system env.
loadEnvironmentVariables() {
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

# Check if HIDORA_MACHINE_ID is set and is a number
checkHidoraMachineId() {
    if [[ -z "${HIDORA_MACHINE_ID}" ]]; then
        echo "HIDORA_MACHINE_ID is not set. Please provide it as an argument or copy it to the clipboard."
        exit 2
    fi
    if ! [[ "${HIDORA_MACHINE_ID}" =~ ^[0-9]+$ ]]; then
        echo "HIDORA_MACHINE_ID must be a number. Please provide a valid ID."
        exit 2
    fi
}

sshToHidora() {
    local ssh_command="${SSH_PROGRAM} ${HIDORA_MACHINE_ID}-${HIDORA_USER_ID}@${HIDORA_SSH_GATE_URL} -p ${HIDORA_SSH_PORT}"
    echo "Connecting to Hidora machine ID: ${HIDORA_MACHINE_ID}${HIDORA_MACHINE_NAME}"
    echo "${ssh_command}"
    ${ssh_command}
}

main() {
    checkRequiredPrograms
    loadParameters "$1"
    loadEnvironmentVariables
    checkHidoraMachineId
    sshToHidora
}

main "$@"