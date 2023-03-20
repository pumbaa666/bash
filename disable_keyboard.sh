#! /usr/bin/bash
# https://www.maketecheasier.com/create-desktop-file-linux/
# Desktop files are located in /usr/share/applications

DEVICE_NAME="AT Translated Set 2 keyboard"
KEYBOARD_ID=$(xinput list | grep "$DEVICE_NAME" | grep -oP 'id=\K[0-9]+')

xinput set-int-prop $KEYBOARD_ID "Device Enabled" 8 0
echo -e "Keyboard (id=$KEYBOARD_ID) disabled"
