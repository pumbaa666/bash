#!/bin/bash

# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
# Source Sebsauvage : https://sebsauvage.net/wiki/doku.php?id=linux-vrac

set -eu
 
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
