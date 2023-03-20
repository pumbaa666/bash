#!/bin/bash

cat /etc/passwd| awk BEGIN{"FS=\":\""}{"printf \"| %-23s | %s | %8d  | %8d  |  %-43s | %-30s | %s\n\", \$1, \$2, \$3, \$4, \$5, \$6, \$7"}|sort -k6,6n
