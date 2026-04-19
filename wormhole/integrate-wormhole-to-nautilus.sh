#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCHE[0]}")" && pwd)"
echo "[DEBUG] SCRIPT_DIR = $SCRIPT_DIR"


echo "Installing dependencies..."
sudo apt install magic-wormhole zenity xclip -y
echo "Dependencies installed."

echo "Setting up Nautilus scripts for Wormhole..."
nautilus_path=~/.local/share/nautilus/scripts # Do not quote to prevent ~-expansion
mkdir -p "$nautilus_path"

# Create symbolic links
cd "$nautilus_path"
ln -s "${SCRIPT_DIR}/wormhole-send.sh" "${nautilus_path}/Wormhole Send"
ln -s "${SCRIPT_DIR}/wormhole-receive.sh" "${nautilus_path}/Wormhole Receive"
echo "Created symbolic links for Wormhole scripts in Nautilus scripts directory : ${nautilus_path}"

# Restart Nautilus
nautilus -q

echo "Successfully integrated Wormhole scripts into Nautilus."