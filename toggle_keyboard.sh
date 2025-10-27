#!/bin/bash

# Script to enable or disable the keyboard using xinput
# Usage: ./toggle_keyboard.sh --enable|--disable [device_name]
# Example: ./toggle_keyboard.sh --disable "AT Translated Set 2 keyboard"

DEVICE_NAME=${2:-"AT Translated Set 2 keyboard"}
KEYBOARD_ID=$(xinput list | grep "$DEVICE_NAME" | grep -oP 'id=\K[0-9]+')

if [ -z "$KEYBOARD_ID" ]; then
    echo "Could not find keyboard: $DEVICE_NAME"
    exit 1
fi

function usage() {
    echo "Usage: $0 [--enable | -e] | [--disable | -d] [device_name]"
    echo "  --enable, -e    Enable the keyboard"
    echo "  --disable, -d   Disable the keyboard"
    echo "  device_name     Optional: Specify a different device name (default: \"${DEVICE_NAME}\")"
    exit 1
}

case "$1" in
    --enable|-e)
        xinput set-int-prop "$KEYBOARD_ID" "Device Enabled" 8 1
        echo "Keyboard (id=$KEYBOARD_ID) enabled"
        ;;
    --disable|-d)
        xinput set-int-prop "$KEYBOARD_ID" "Device Enabled" 8 0
        echo "Keyboard (id=$KEYBOARD_ID) disabled"
        ;;
    *)
        usage
        ;;
esac

exit 0
