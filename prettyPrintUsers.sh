#!/bin/bash

# This script pretty prints the content of the /etc/passwd file
# It formats the output in a table-like structure with columns for
# username, password, user ID, group ID, user ID info, home directory, and command/shell.
# The output is sorted by the 6th column (home directory).

cat /etc/passwd| awk BEGIN{"FS=":""}{"printf "| %-23s | %s | %8d  | %8d  |  %-43s | %-30s | %s\n", $1, $2, $3, $4, $5, $6, $7"}|sort -k6,6n