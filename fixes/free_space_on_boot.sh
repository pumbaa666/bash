#!/bin/bash
# https://askubuntu.com/questions/89710/how-do-i-free-up-more-space-in-boot
# Reclaim space from old kernels

# One command to show all kernels and headers that can be removed, excluding the current running kernel:
current_kernel=$(uname -r | sed -r 's/-[a-z]+//')
old_kernels=$(dpkg -l linux-{image,headers}-"[0-9]*" | awk '/ii/{print $2}' | grep -ve $current_kernel)

if [ -z "$old_kernels" ]; then
    echo "No old kernels to remove"
    exit 0
fi

echo "The following kernels will be removed:"
echo "$old_kernels"
sudo apt-get purge $old_kernels

# To list all installed kernels, run:
# dpkg -l linux-image-\* | grep ^ii