#!/bin/bash

echo "Installing dependencies..."
sudo apt install magic-wormhole zenity xclip -y
echo "Dependencies installed."

echo "Setting up Nautilus scripts for Wormhole..."
nautilus_path="~/.local/share/nautilus/scripts/"
mkdir -p "$nautilus_path"

# Create symbolic links
ln -s ./wormhole-send.sh "${nautilus_path}/Wormhole Send"
ln -s ./wormhole-receive.sh "${nautilus_path}/Wormhole Receive"
echo "Created symbolic links for Wormhole scripts in Nautilus scripts directory : ${nautilus_path}"

# Restart Nautilus
nautilus -q

echo "Successfully integrated Wormhole scripts into Nautilus."