#!/bin/bash

# This program lists all IP addresses of the machine and allows the user to select one to copy to clipboard using arrow keys.
# Requires xclip to copy to clipboard.
# If xclip is not installed, it will just print the selected IP address.
# If -i option is provided, it ignores loopback and IPv6 addresses.

XCLIP_PATH=""

# Colors
RED='\033[0;31m'
BG_RED='\033[41m'
CYAN='\033[0;36m'
BG_CYAN='\033[46m'
GREEN='\033[0;32m'
RESET='\033[0m'

checkRequiredPrograms() {
    XCLIP_PATH="$(which xclip)"
    if [[ -z "${XCLIP_PATH}" ]] ; then
        echo -e "[WARN] xclip is not installed, the programm won't be able to write to clipboard."
        echo -e "On Debian/Ubuntu, you can install it with:\n    sudo apt install xclip"
    fi
}

function getIps() {
    local ignoreUseless=${1:-"false"}
    if [[ "${ignoreUseless}" == "true" ]]; then
        ifconfig | grep inet | grep -v "127.0.0.1" | grep -v "::" | grep -Ev "^addr:[ \t]*$" | awk '{print $2}' | sed 's/addr://g'
    else
        ifconfig | grep inet | grep -Ev "^addr:[ \t]*$" | awk '{print $2}' | sed 's/addr://g'
    fi
}

# Only exit when called from ctrl-c
function cleanup() {
    local exit_type="$1"
    tput cnorm
    tput rmcup
    if [[ "${exit_type}" != "dontexit" ]]; then
        exit 0
    fi
}

function main() {
    checkRequiredPrograms

    local ignoreUseless="false"
    for arg in "$@"; do
        if [[ "$arg" == "-i" ]]; then
            ignoreUseless="true"
            break
        fi
    done

    mapfile -t ips < <(getIps "$ignoreUseless")
    local selected=0

    if [[ ${#ips[@]} -eq 0 ]]; then
        echo "No IP addresses found."
        exit 0
    fi

    local selected=0
    
    trap cleanup INT TERM
    menu_height=$((${#matching_machines[@]} + 1))
    tput smcup # Enter alternate screen
    tput civis # Hide cursor

    while true; do
        tput cup 0 0   # move cursor to top-left
        echo "Select an IP address (UP/DOWN to navigate, ENTER to copy, ESC to quit):"
        for i in "${!ips[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${BG_CYAN} > ${ips[$i]}${RESET}"
            else
                echo "   ${ips[$i]}"
            fi
        done
        tput el # clear leftovers if menu shrank

        # Read user input
        read -rsn1 key
        if [[ "$key" == $'' ]]; then
            read -rsn1 -t 0.1 key
            if [[ "$key" == "[" ]]; then
                read -rsn1 key
                if [[ "$key" == "A" ]]; then # Up
                    selected=$(( (selected - 1 + ${#ips[@]}) % ${#ips[@]} ))
                elif [[ "$key" == "B" ]]; then # Down
                    selected=$(( (selected + 1) % ${#ips[@]} ))
                fi
            else # Escape
                cleanup "dontexit"
                return 1
            fi
        elif [[ "$key" == "" ]]; then # Enter
	        cleanup "dontexit"
            if [[ -n "${XCLIP_PATH}" ]]; then
                echo -n "${ips[$selected]}" | xclip -selection clipboard
                echo -e "Copied ${CYAN}${ips[$selected]}${RESET} to clipboard."
            else
                echo -e "${ips[$selected]}"
            fi
            return 0
        fi
    done
}

main "$@"
