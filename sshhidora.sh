#!/bin/bash

# PARAMETERS
ENV_FILE_PATH="$(dirname "$0")/sshhidora.env"

# ENVIRONMENT VARIABLES
HIDORA_USER_ID=""
HIDORA_SSH_GATE_URL=""
HIDORA_SSH_PORT=""

# GLOBAL VARIABLES
ABSTRACT_PARAMETER=""
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
    echo "Usage: $0 HIDORA_MACHINE_ID | HIDORA environment name, container name, ... [OPTIONS]"
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
}

# Load parameters
# This function loads the HIDORA_MACHINE_ID from the command line argument or clipboard if not provided.
function loadParameters() {
    if [[ "$#" -eq 1 ]]; then
        case $1 in
            -h|--help)  usage; exit 0 ;;
            -*)         echo "Unknown option: $1" ; usage; exit 1 ;;
        esac
    fi

    if [[ "$#" -gt 0 ]]; then
        ABSTRACT_PARAMETER="$*"
    fi

    if [[ -n "${ABSTRACT_PARAMETER}" ]]; then
        return 0
    fi

    # Load clipboard value into ABSTRACT_PARAMETER
    if [[ -n "${XCLIP_PROGRAM}" ]]; then
        ABSTRACT_PARAMETER=$(xclip -o -selection clipboard)
    fi

    # Check if ABSTRACT_PARAMETER is set and is a number
    if [[ ! "${ABSTRACT_PARAMETER}" =~ ^[0-9]+$ ]]; then
        echo "Argument is not set. Please provide it or copy it to the clipboard (needs xclip)."
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
        exit 3
    fi
}

# Find machine ID and name from the correspondence array
# This function sets HIDORA_MACHINE_ID and HIDORA_MACHINE_NAME based on ABSTRACT_PARAMETER
# It searches MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE for a matching name or container name.
# It will take an arbitrary number of arguments (separated by spaces) and refine the matching machines.
# If it finds a single match, it sets HIDORA_MACHINE_ID and HIDORA_MACHINE_NAME accordingly.
# Else, it presents a selection menu to the user to choose the desired machine, setting HIDORA_MACHINE_ID and HIDORA_MACHINE_NAME.
function getMachineNameAndIdFromName() {
    function splitIdAndName() {
        local matching_machines="$1"
        local environment_name container_name
        IFS=':' read -r HIDORA_MACHINE_ID environment_name container_name <<< "${matching_machines}"
        HIDORA_MACHINE_NAME=" [${BG_CYAN}${environment_name}${RESET}] ${CYAN}${container_name}${RESET}"
    }

    local search_terms=()
    IFS=' ' read -ra search_terms <<< "${ABSTRACT_PARAMETER}"

    # No correspondence table, cannot find ID from name
    if [[ -z "${MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE}" ]] ; then
        echo "[ERROR] No MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE defined, cannot find machine ID from name." >&2
        return 9
    fi

    # Use comma as separator
    local pairs=()
    IFS=',' read -ra pairs <<< "${MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE}"

    local matching_machines=()

    # Initial population of matching_machines with all machines
    for pair in "${pairs[@]}"; do
        matching_machines+=("$pair")
    done

    # Refine matching_machines based on search terms
    local previous_count="${#matching_machines[@]}"
    local current_count
    local i=0
    for term in "${search_terms[@]}"; do
        local term_lowercase="${term,,}"
        local refined_matches=()
        for machine in "${matching_machines[@]}"; do
            local machine_lowercase="${machine,,}"
            if [[ "$machine_lowercase" == *"$term_lowercase"* ]]; then
                refined_matches+=("$machine")
            fi
        done
        matching_machines=("${refined_matches[@]}")

        current_count="${#matching_machines[@]}"
        if [[ ${current_count} == ${previous_count} ]]; then
            continue
        fi

        if [[ ${current_count} == 1 ]]; then
            # Found a single match, stop refining
            splitIdAndName "${matching_machines[0]}"
            tput cnorm # Restore cursor
            return 0
        fi

        previous_count="${current_count}"
        ((i++))
    done

    if [[ ${current_count} == 0 ]]; then
        echo "[ERROR] No machine found matching the provided name/container name ('${ABSTRACT_PARAMETER}')." >&2
        return 2
    fi

    local selected=0
    
    tput civis # Hide cursor
    trap 'tput cnorm; exit' INT # Trap Ctrl+C and restore cursor

    while true; do
        # Clear screen and print menu
        tput clear
        echo "Select the desired machine (UP/DOWN to navigate, ENTER to copy, ESC to quit):"
        for i in "${!matching_machines[@]}"; do
            if [[ $i -eq $selected ]]; then
                tput setaf 2 # Green
                echo " > ${matching_machines[$i]}"
                tput sgr0 # Reset color
            else
                echo "   ${matching_machines[$i]}"
            fi
        done

        # Read user input
        read -rsn1 key
        if [[ "$key" == $'' ]]; then
            read -rsn1 -t 0.1 key
            if [[ "$key" == "[" ]]; then
                read -rsn1 key
                if [[ "$key" == "A" ]]; then # Up
                    selected=$(( (selected - 1 + ${#matching_machines[@]}) % ${#matching_machines[@]} ))
                elif [[ "$key" == "B" ]]; then # Down
                    selected=$(( (selected + 1) % ${#matching_machines[@]} ))
                fi
            else # Escape
                tput cnorm # Restore cursor
                return 1
            fi
        elif [[ "$key" == "" ]]; then # Enter
            splitIdAndName "${matching_machines[$selected]}"
            tput cnorm # Restore cursor
            return 0
        fi
    done
}

# Find machine name from the correspondence array
function getMachineNameFromId() {
    HIDORA_MACHINE_ID="${ABSTRACT_PARAMETER}"

    # No correspondence table, so no name
    if [[ -z "${MACHINE_ID_TO_CONTAINER_NAME_CORRESPONDENCE}" ]] ; then
        return 9
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
            return 0
        fi
    done

    return 1
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

    if [[ -z "${ABSTRACT_PARAMETER}" ]]; then
        echo "[ERROR] No machine ID or name provided." >&2
        exit 2
    fi
    
    if [[ "${ABSTRACT_PARAMETER}" =~ ^[0-9]+$ ]]; then
        getMachineNameFromId
    else
        getMachineNameAndIdFromName
    fi

    if [[ $? -ne 0 ]]; then
        exit $?
    fi
    sshToHidora
}

main "$@"