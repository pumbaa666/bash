#!/usr/bin/env bash

# This program lists all IP addresses of the machine and allows the user to select one to copy to clipboard using arrow keys.
# Requires xclip to copy to clipboard.
# If xclip is not installed, it will just print the selected IP address.
# If -i option is provided, it ignores loopback and IPv6 addresses.

RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
BG_CYAN=$'\033[46m'
RESET=$'\033[0m'

XCLIP=""

function check_requirements() {
    if command -v xclip >/dev/null 2>&1; then
        XCLIP=$(command -v xclip)
    else
        echo -e "[WARN] xclip is not installed, the program won't be able to write to clipboard."
        echo -e "On Debian/Ubuntu, you can install it with:\n    sudo apt install xclip"
    fi
}

function get_ips() {
    local ignore_useless="${1:-false}"

    if [[ "$ignore_useless" == "true" ]]; then
        ip -o addr show scope global | awk '{print $4}' | cut -d/ -f1
    else
        ip -o addr show | awk '{print $4}' | cut -d/ -f1
    fi
}

# Only exit when called from ctrl-c
function restore_terminal() {
    local exit_type="$1"
    tput rmcup
    tput cnorm
    stty sane
    if [[ "${exit_type}" != "dontexit" ]]; then
        exit 0
    fi
}

function enter_terminal() {
    tput smcup
    tput civis
    stty -echo -icanon time 0 min 1
}

function draw_menu() {
    local selected="$1"
    shift
    local items=("$@")

    tput cup 0 0
    echo "Select IP (↑/↓ navigate, Enter select, Esc quit)"

    for i in "${!items[@]}"; do
        if [[ $i -eq $selected ]]; then
            printf " > %s\n" "${BG_CYAN}${items[$i]}${RESET}"
        else
            printf "   %s\n" "${items[$i]}"
        fi
    done
}

function read_key() {
    local k
    IFS= read -rsn1 k

    if [[ $k == $'\x1b' ]]; then
        read -rsn1 -t 0.01 k || { echo ESC; return; }
        if [[ $k == "[" ]]; then
            read -rsn1 k
            case "$k" in
                A) echo UP ;;
                B) echo DOWN ;;
            esac
        else
            echo ESC
        fi
        return
    fi

    [[ $k == "" ]] && echo ENTER
}

function copy_ip() {
    local ip="$1"

    if [[ -n "$XCLIP" ]]; then
        printf "%s" "$ip" | xclip -selection clipboard
        echo "Copied ${CYAN}${ip}${RESET} to clipboard"
    else
        echo "$ip"
    fi
}

function main() {
    check_requirements

    local ignore_useless=false
    [[ "${1:-}" == "-i" ]] && ignore_useless=true

    mapfile -t ips < <(get_ips "$ignore_useless")

    [[ ${#ips[@]} -eq 0 ]] && { echo "No IP addresses found."; exit 1; }

    local selected=0

    trap restore_terminal INT TERM
    enter_terminal

    while true; do
        draw_menu "$selected" "${ips[@]}"

        case "$(read_key)" in
            UP)
                ((selected--))
                ((selected<0)) && selected=$((${#ips[@]}-1))
                ;;
            DOWN)
                ((selected++))
                ((selected>=${#ips[@]})) && selected=0
                ;;
            ENTER)
                restore_terminal "dontexit"
                copy_ip "${ips[$selected]}"
                exit 0
                ;;
            ESC)
                restore_terminal "dontexit"
                exit 1
                ;;
        esac
    done
}

main "$@"
