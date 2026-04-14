#!/bin/bash

PID="${1:?Error: No PID provided. Usage: $0 <PID> [FOLDER_TO_WATCH] [SLEEP_TIME]}"
FOLDER_TO_WATCH="${2:-.}"
SLEEP_TIME="${3:-10}"

while true; do
    kill -0 $PID 2>/dev/null || break

    echo -e "\nProcess with PID $PID is still running."
    ls -alh "$FOLDER_TO_WATCH"
    sleep $SLEEP_TIME
done
echo "Finished !"
