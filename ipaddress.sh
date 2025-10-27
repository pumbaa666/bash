#!/bin/bash

# This program lists all IP addresses of the machine and allows the user to select one to copy to clipboard using arrow keys.
# Requires xclip to copy to clipboard.
# If xclip is not installed, it will just print the selected IP address.
# If -i option is provided, it ignores loopback and IPv6 addresses.

XCLIP_PATH=""

# Colors
RED='\033[0;31m'
BG_RED='\033[41m'
RESET='\033[0m'

checkRequiredPrograms() {
    XCLIP_PATH="$(which xclip)"
    if [[ -z "${XCLIP_PATH}" ]] ; then
        echo -e "[WARN] xclip is not installed, the programm won't be able to write to clipboard."
        echo -e "On Debian/Ubuntu, you can install it with:\n    sudo apt install xclip"
    fi
}

function getIps() {
    local ignoreUseless=${1}
    if [[ "${ignoreUseless}" == "true" ]]; then
        ifconfig | grep inet | grep -v "127.0.0.1" | grep -v "::" | grep -Ev "^addr:[ \t]*$" | awk '{print $2}' | sed 's/addr://g'
    else
        ifconfig | grep inet | grep -Ev "^addr:[ \t]*$" | awk '{print $2}' | sed 's/addr://g'
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

    # Hide cursor
    tput civis

    # Trap Ctrl+C and restore cursor
    trap 'tput cnorm; exit' INT

    while true; do
        # Clear screen and print menu
        tput clear
        echo "Select an IP address (UP/DOWN to navigate, ENTER to copy, ESC to quit):"
        for i in "${!ips[@]}"; do
            if [[ $i -eq $selected ]]; then
                tput setaf 2 # Green
                echo " > ${ips[$i]}"
                tput sgr0 # Reset color
            else
                echo "   ${ips[$i]}"
            fi
        done

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
                break
            fi
        elif [[ "$key" == "" ]]; then # Enter
            tput cnorm # Restore cursor
            tput clear
            if [[ -n "${XCLIP_PATH}" ]]; then
                echo -n "${ips[$selected]}" | xclip -selection clipboard
                echo -e "Copied ${RED}${ips[$selected]}${RESET} to clipboard."
            else
                echo -e "${ips[$selected]}"
            fi
            break
        fi
    done

    # Restore cursor
    tput cnorm
}

main "$@"