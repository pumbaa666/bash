#!/usr/bin/env bash

# This script allows you to connect/disconnect to OpenVPN and view logs from a system tray icon using YAD.
# Licence GPlv3 : https://www.gnu.org/licenses/gpl-3.0.html
#
# Author : Pumbaa

# YAD documentation : https://yad-guide.ingk.se/entry/yad-entry.html

VPN_NAME="hostinger-vpn"
VPN_CONF="/etc/openvpn/client/client.conf"
LOG="/tmp/${VPN_NAME}.log"
OPENVPN_PID_FILE="/tmp/${VPN_NAME}.openvpn.pid"
YAD_PID_FILE="/tmp/${VPN_NAME}.yad.pid"

function log_debug() {
    echo "[DEBUG] $1" >&2
}

function log_error() {
    echo "[ERROR] $1" >&2
}

# Check if required programs are installed on the system
# Usage : check_program_is_installed "program1" "program2" ...
# Exits with code 2 if any program is missing
function check_program_is_installed() {
    local programs="${*}"
    if [[ -z "${programs}" ]]; then
        log_error "check_program_is_installed: program name is empty"
        exit 3
    fi

    local missing=0
    for program in ${programs}; do
        if ! command -v "${program}" &> /dev/null; then
            log_error "'${program}' is required but not installed"
            ((missing++))
        fi
    done

    if [[ ${missing} -gt 0 ]]; then
        log_error "Missing programs: ${missing}"
        exit 2
    fi
}

# Test if user already ran sudo recently, if not ask for password and validate it
# Returns 0 if sudo is available, 1 if user cancelled or entered wrong password
function sudo_check() {
    sudo -n true > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        log_debug "User has not recently run sudo, will ask for password"
        log_debug "Asking for sudo password to launch OpenVPN"
        local password=$(yad --hide-text --text-align=center --title="OpenVPN" --text="Enter your password to connect to OpenVPN" --entry --entry-label=Label --entry-text="")
        
        if [[ -z "$password" ]]; then
            log_debug "No password entered, aborting connection"
            notify-send "OpenVPN" "Connection aborted"
            return 1
        fi
        log_debug "Password entered, validating password"
        sudo -S echo "Password accepted" <<< "$password" > /dev/null 2>&1
        unset password
        if [[ $? -ne 0 ]]; then
            log_debug "Incorrect password entered, aborting connection"
            notify-send "OpenVPN" "Incorrect password, connection aborted"
            return 1
        fi
    else
        log_debug "User has recently run sudo, will not ask for password"
        return 0
    fi
}

# the kill -0 command sends signal 0 (no action) to the process without affecting it. If the PID exists and is running, the command returns success (exit code 0)
function is_running() {
    [[ -f "$1"  ]] && kill -0 "$(cat "$1")" 2>/dev/null
}

function set_icon() {
    return

    echo "icon:$1" > "$PIPE"
}

function disconnect() {
    log_debug "disconnect"
    log_debug "looking for PID file at $OPENVPN_PID_FILE"

    if [[ -f "$OPENVPN_PID_FILE" ]]; then
        sudo_check || return
        notify-send "OpenVPN" "Disconnecting"
        sudo kill "$(cat "$OPENVPN_PID_FILE")"
        sudo rm -f "$OPENVPN_PID_FILE"
        notify-send "OpenVPN" "Disconnected"
        set_icon network-vpn-disconnected
    fi
}

function connect() {
    log_debug "connect"

    # Check if OpenVPN is already running by checking the PID file
    log_debug "looking for PID file at $OPENVPN_PID_FILE"
    if [[ -f "$OPENVPN_PID_FILE" ]] && is_running "$OPENVPN_PID_FILE"; then
        log_debug "PID file found, with PID $(cat "$OPENVPN_PID_FILE")"
        echo "Already connected"
        notify-send "OpenVPN" "Already connected"
        return
    fi

    sudo_check || return

    log_debug "launching OpenVPN with config $VPN_CONF, logging to $LOG and PID file at $OPENVPN_PID_FILE"
    set_icon network-vpn-acquiring
    notify-send "OpenVPN" "Connecting"
    sudo openvpn \
        --config "$VPN_CONF" \
        --daemon \
        --writepid "$OPENVPN_PID_FILE" \
        --log "$LOG" \
        --status "/tmp/${VPN_NAME}.status"

    log_debug "Waiting for OpenVPN to connect, checking log for 'Initialization Sequence Completed'"
    local i=0
    local max_tries=30
    while ! sudo grep -q "Initialization Sequence Completed" "$LOG"; do
        echo "$i / $max_tries ..."
        sleep 1
        ((i++))
        if [[ $i -gt $max_tries ]]; then
            notify-send "OpenVPN" "Connection timed out"
            disconnect
            return
        fi
    done

    log_debug "Connected !"
    set_icon network-vpn-connected
    notify-send "OpenVPN" "Connected"
}

function show_logs() {
    log_debug "show_logs"

    # Prevent opening multiple log windows if the user clicks multiple times on "Logs" in the menu
    pgrep -f "yad --text-info --tail --filename=$LOG" >/dev/null && log_debug "Log window already open" && return

    yad --text-info --tail --filename="$LOG" --width=800 --height=400
}

function status() {
    log_debug "status"
    if [[ -f "$OPENVPN_PID_FILE" ]] && is_running "$OPENVPN_PID_FILE"; then
        echo "Connected"
        notify-send "OpenVPN" "Connected"
    else
        echo "Disconnected"
        notify-send "OpenVPN" "Disconnected"
    fi
}

function quit() {
    disconnect
    if [[ ! -f "$YAD_PID_FILE" ]]; then
        log_debug "No YAD PID file found, nothing to kill"
        return
    fi
    yad_pid="$(cat "$YAD_PID_FILE")"
    log_debug "Killing YAD process with PID $yad_pid"
    rm -f "$YAD_PID_FILE" # YAD tmp file is created with user permissions, so we can remove it without sudo
    kill "$yad_pid" 2>/dev/null
}

function tray(){
    if is_running "$YAD_PID_FILE"; then
        log_debug "Tray already running"
        exit
    fi

    log_debug "Add OpenVPN to systray with yad"

    # Controle pipe file for communication between YAD and the script.
    # Will be used to update icon
    PIPE="/tmp/${VPN_NAME}.yad.pipe"
    mkfifo "$PIPE"

    yad \
    --notification \
    --image=network-vpn \
    --text="OpenVPN" \
    --menu="Status!$0 status|Connect!$0 connect|Disconnect!$0 disconnect|Logs!$0 show_logs|Quit!$0 quit" \
    < "$PIPE" &

    yad_pid=$!
    echo $yad_pid > $YAD_PID_FILE
    log_debug "YAD PID: $yad_pid saved in $YAD_PID_FILE"
}

check_program_is_installed "yad" "openvpn" "notify-send"

if [[ ! -r "$VPN_CONF" ]]; then
    log_error "VPN configuration file '$VPN_CONF' is not readable. Exiting."
    exit 1
fi

case "$1" in
    tray) tray ;;
    connect) connect ;;
    disconnect) disconnect ;;
    show_logs) show_logs ;;
    status) status ;;
    quit) quit ;;
    *) tray ;;
esac
