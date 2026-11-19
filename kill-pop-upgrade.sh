#!/bin/env bash

# This script is called every hour by a cron job.
# It kills the hanging `pop-upgrade` which I cannot disable unfortunately.

PROCESS_NAME="pop-upgrade"
echo "[INFO] Looking for '${PROCESS_NAME}' process"

pid=""
i=1
max_tries=30
while pgrep ${PROCESS_NAME} ; do
    pid="$(pgrep ${PROCESS_NAME} | head -n 1)" 
    echo "[INFO] Killing process # ${pid}"
    sudo kill -9 "${pid}"

    echo "[DEBUG] waiting 1s... (${i} / ${max_tries})"
    sleep 1

    if ((i == max_tries)); then
        echo "[WARN] Max tries (${max_tries}) reached, exiting"
        break
    fi
    ((i++))
done

echo "[INFO] Done"
