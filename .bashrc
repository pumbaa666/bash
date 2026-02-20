# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Text colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Text colors (bold)
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Background colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Other modifiers
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# =============================================================================
# History Control
# =============================================================================
# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it.
shopt -s histappend
# Set history length.
HISTSIZE=10000
HISTFILESIZE=10000

# =============================================================================
# Shell Options
# =============================================================================
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# =============================================================================
# Prompt
# =============================================================================
# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

function parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ' # original
    #PS1='\e[1;35m\u@\h\e[1;32m \w $ \e[0m' #source : http://lehollandaisvolant.net/?d=2014/06/06/15/58/11-gnulinux-ameliorer-le-terminal
    PS1="\[\e[00;92m\]\u\[\e[0m\]\[\e[00;37m\]@\H \[\e[0m\]\[\e[00;33m\]\t\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;32m\]\w\[\e[0m\]\[\e[00;37m\] \[\e[91m\]\$(parse_git_branch)\[\e[00m\] \[\e[0m\]\[\e[00;35m\]\\$\[\e[0m\]\[\e[00;37m\] \[\e[0m\]" #source : http://bashrcgenerator.com ; https://thucnc.medium.com/how-to-show-current-git-branch-with-colors-in-bash-prompt-380d05a24745
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ' # original
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# =============================================================================
# Aliases
# =============================================================================
# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## Pumbaa

# Don't interrupt script on errors
set +e
# Interrupt script on first error
# set -e

# Silly script
# https://lehollandaisvolant.net/?q=cowsay
[[ -x "$(command -v cowsay)" && -x "$(command -v fortune)" ]] && fortune -a | cowsay -f $(shuf -n1 -e hellokitty default tux moose)

alias l='ls -alh'
alias lr='ls -ralth'
alias lg='ls -alh | grep -i $1'
alias lx='folderSize'
alias highlight='rg --passthru' # source : https://youtu.be/NE3ftNlfkdw?t=4825
alias hl='highlight'
alias matrix='cmatrix -a -b -u 3'
alias vscode='code'
alias open="xdg-open"
alias plz='/usr/bin/sudo $(history -p !!)'
alias kb-enable='~/programmation/perso/bash/toggle_keyboard.sh --enable'
alias kb-disable='~/programmation/perso/bash/toggle_keyboard.sh --disable'
alias flipper='/opt/flipper-zero/AppRun'
alias 7zip='7za x'
alias opnk='python3 /home/lcorrevon/programmation/perso/offpunk/offpunk.py'
alias gdiff='git_diff'
alias easyHttpServer='python3 -m http.server 5555'
alias rebootToBios='systemctl reboot --firmware-setup'
alias top10='history | awk '\''{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}'\'' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10'
alias bat='batcat' # https://github.com/sharkdp/bat
alias ipaddress='~/programmation/perso/bash/ipaddress.sh -i'

function myHelp() {
    echo -e "${GREEN}# Aliases${RESET}"
    echo -e "${CYAN}l${RESET} ${ITALIC}ls -alh${RESET}\t\t\tPrints files list with human readable sizes"
    echo -e "${CYAN}lg${RESET} ${ITALIC}ls -alh | grep -i \$1${RESET}\t\tSearch a filename in the current directory"
    echo -e "${CYAN}lx${RESET} ${ITALIC}folderSize${RESET}\t\t\tShows directory size recursively"
    echo -e "${CYAN}hl, highlight${RESET}\t\t\tHighlight text using rg (ripgrep)"
    echo -e "${CYAN}code${RESET} ${ITALIC}vscode${RESET}\t\t\tLaunch Microsoft VSCode, code editor"
    echo -e "${CYAN}open${RESET} ${ITALIC}file${RESET}\t\t\tOpen a file with the default application"
    echo -e "${CYAN}plz${RESET}\t\t\t\tExecute the last command with sudo"
    echo -e "${CYAN}kb-enable${RESET} ${ITALIC}enable_keyboard.sh${RESET}\tEnable the built-in (laptop) keyboard"
    echo -e "${CYAN}kb-disable${RESET} ${ITALIC}disable_keyboard.sh${RESET}\tDisable the built-in (laptop) keyboard"
    echo -e "${CYAN}flipper${RESET}\t\t\t\tLaunch Flipper Zero interface"
    echo -e "${CYAN}7zip${RESET} ${ITALIC}file${RESET}\t\t\tExtract 7zip file"
    echo -e "${CYAN}opnk${RESET}\t\t\t\tTerminal browser with caching capabilities. See ${UNDERLINE}https://offpunk.net/${RESET}"
    echo -e "${CYAN}gdiff${RESET}\t\t\t\tShow git diff with visual representation"
    
    echo -e "${CYAN}easyHttpServer${RESET}\t\t\tLaunch a HTTP server from the directory, allowing to download files from HTTP"
    echo -e "${CYAN}rebootToBios${RESET}\t\t\tExplicit"
    echo -e "${CYAN}top10${RESET}\t\t\t\tShow the 10 most used commands in history"
    echo -e ""

    echo -e "${GREEN}# Files and pictures${RESET}"
    echo -e "${BOLD_YELLOW}cd(${YELLOW}${ITALIC}search,replace${BOLD_YELLOW})${RESET}\t\tRecursively change directory by replacing part of the path"
    echo -e "${BOLD_YELLOW}folderSize(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\tRecursively show the size of a folder and its subfolders"
    echo -e "${BOLD_YELLOW}countFiles(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\tRecursively count the number of regular files in a folder"
    echo -e "${BOLD_YELLOW}mygrep(${YELLOW}${ITALIC}search_patern${BOLD_YELLOW})${RESET}\t\tPretty grep"
    echo -e "${BOLD_YELLOW}chownwww(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\t\tApplies www-data user and group to a file or directory, recursively"

    echo -e "${BOLD_YELLOW}createFileDate(${YELLOW}${ITALIC}name, ext${BOLD_YELLOW})${RESET}\tCreates an empty file with the current date and time in its name"
    echo -e "${BOLD_YELLOW}backupFileDate(${YELLOW}${ITALIC}name${BOLD_YELLOW})${RESET}\t\tBacks up a file, optionally with a timestamp"
    echo -e "${BOLD_YELLOW}renameFiles(${YELLOW}${ITALIC}path,search,replace${BOLD_YELLOW})${RESET}Renames all files in the specified directory"
    echo -e "${BOLD_YELLOW}resizePictures(${YELLOW}${ITALIC}path, size${BOLD_YELLOW})${RESET}\tResizes all images in a directory"
    echo -e "${BOLD_YELLOW}searchWord(${YELLOW}${ITALIC}word, (path)${BOLD_YELLOW})${RESET}\tShows files where the word appears"

    echo -e "${BOLD_YELLOW}colorLogs(${YELLOW}${ITALIC}file, (part), (size)${BOLD_YELLOW})${RESET}\tPrint colored logs"
    echo -e ""

    echo -e "${GREEN}# Docker${RESET}"
    echo -e "${BOLD_YELLOW}dockersh(${YELLOW}${ITALIC}container_name${RESET}${BOLD_YELLOW})${RESET}\tJumps into container as /bin/sh"
    echo -e "\t${BOLD_YELLOW}dcsh(${YELLOW}${ITALIC}container_name${BOLD_YELLOW})${RESET}"
    echo -e "${BOLD_YELLOW}dockerlogs(${YELLOW}${ITALIC}container_name${RESET}${BOLD_YELLOW})${RESET}\tPrints container logs"
    echo -e "\t${BOLD_YELLOW}dclogs(${YELLOW}${ITALIC}container_name${BOLD_YELLOW})${RESET}"
    echo -e ""

    echo -e "${GREEN}# Git${RESET}"
    echo -e "${BOLD_YELLOW}git_diff${RESET}\t\t\tShow git diff with visual representation"

    echo -e "${GREEN}# Users${RESET}"
    echo -e "${BOLD_YELLOW}prettyPrintUsers${RESET}\t\tPrints the OS users in a nice array"
    echo -e "${BOLD_YELLOW}allCrontabs${RESET}\t\t\tPrint the crontab of each user on this machine"
    echo -e ""
    
    echo -e "${GREEN}# Perso${RESET}"
    echo -e "${BOLD_YELLOW}mountNetworkShares${RESET}\t\tMount network folders (Commun)"
    echo -e "${BOLD_YELLOW}clearBoot${RESET}\t\t\tRemove all old kernels except the current one"
    echo -e ""

    echo -e "${GREEN}# Help${RESET}"
    echo -e "Custom ${BOLD_BLUE}docker${RESET} config in ${ITALIC}~/.docker/config.json${RESET}"
    echo -e "Custom ${BOLD_BLUE}sshrc${RESET} config in ${ITALIC}~/.sshrc${RESET} to copy the local .bashrc to any distant machine with ssh"
    echo -e "\tUsage${RESET} : \"sshrc ${ITALIC}\$USERNAME${RESET}@${ITALIC}\$SERVER${RESET} -p ${ITALIC}\$PORT${RESET}\""
}

# Change directory by replacing part of the path
# Usage: cd <old_string> <new_string>
# Example:
#    user@machine /tmp/abc/def/ghi/jkl $ cd def DEF
#    user@machine /tmp/abc/DEF/ghi/jkl $
# If only one parameter is provided, it behaves like a normal cd command
#
# the "builtin" command forces the use of the built-in cd command, avoiding recursion
# Idea from https://matthieuamiguet.ch/blog/cd-sous-zsh/
function cd() {
    case $# in
        1) builtin cd "$1" ;;
        2) builtin cd "$(pwd | sed "s/$1/$2/")" ;;
        *) builtin cd "$@" ;;
    esac
}

# Remove all old kernels except the current one
# The upgrade needs a total of XXX M free space on disk '/boot'. Please free at least an additional XXX M of disk space on '/boot'
# https://gist.github.com/harshalbhakta/887e4521a1043d36979b
function clearBoot() {
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
}

# Apply www-data user and group to a file or directory, recursively
# I made a function instead of an alias because I couldn't pass an alias to sudo
# https://superuser.com/questions/1220872/how-can-i-pass-an-alias-to-sudo
function chownwww(){
    sudo chown -R www-data:www-data $*
}

# Grep lisible
# source : http://doc.ubuntu-fr.org/alias
function mygrep(){
    local word="$1"
    local path="${2:-.}"  # If no path is provided, use current folder
	grep -Rins --color -A 5 -B 5 $word $path
}

function findDuplicate () {
    local file_name="$1"
    if [[ -z "$file_name" ]]; then
        echo "Usage: findDuplicate <file_name>"
        return 1
    fi
    if [[ ! -f "$file_name" ]]; then
        echo "Error: File '$file_name' does not exist."
        return 1
    fi
    awk 'NF && $1!~/^(#|HostKey)/{print $1}' "${file_name}" | sort | uniq -c | grep -v ' 1 '
}

# Show the size of a folder and its subfolders
#
# Arguments:
#   $1 - Path to the folder to analyze. If not provided, defaults to the current directory.
#   $2 - Optional: Maximum number of results to display. Defaults to 50.
#   $3 - Optional: File or file descriptor where error messages should be redirected.
#        Defaults to /dev/null (i.e., errors are suppressed).
#
# Behavior:
#   - Lists immediate children of the specified folder and displays their sizes.
#   - Handles folder names with spaces and special characters safely.
#   - Suppresses or redirects errors (e.g., permission denied) as specified.
#
# Usage:
#   folderSize                      # Show size of the current folder and subfolder
#   folderSize PATH                 # Show size of PATH folder and subfolder
#   folderSize PATH MAX_RESULTS     # Show size of PATH folder and subfolder, limiting to MAX_RESULTS
#   folderSize PATH MAX_RESULTS /dev/stderr     # Show size of PATH folder and subfolder and print errors
#
# Originaly written as a simple alias
#   alias lx='for folder in $(ls -A) ; do du -hs "$folder" ; done ; du -hs'
# Source : http://www.linuxquestions.org/questions/linux-general-1/cmdline-howto-know-size-of-folder-recursive-569884/
function folderSize() {
    local path="${1:-.}"  # Default to current directory if no path is provided
    local max_results="${2:-50}"  # Maximum number of results to display. Default to 50
    local err_output="${3:-/dev/null}"  # Error output. Default to /dev/null to get rid of unwanted message

    if [[ ! -d "$path" ]]; then
        echo "Error: '$path' is not a valid directory." >&2
        return 1
    fi
    
    function human_readable_size() {
        local size=$1
        local units=("KB" "MB" "GB" "TB") # "B" is not needed since du -s returns size in KB by default
        local unit_index=0

        while ((size >= 1024 && unit_index < ${#units[@]} - 1)); do
            size=$((size / 1024))
            ((unit_index++))
        done

        echo "${size}${units[$unit_index]}"
    }

    function clean_folder_name() {
        local folder="$1"
        if [[ "$folder" == "__CURRENT__" ]]; then
            echo "Current Folder"
        else
            echo "${folder#./}"
        fi
    }

    function print_visual_percentage() {
        local percentage="$1"
        local bar_length="${2:-20}"
        local filled_length=$((percentage * bar_length / 100))
        printf "[%-${bar_length}s]" "$(printf '%*s' "$filled_length" | tr ' ' '#')"
    }

    # Get the size of each sub-folder and files of the specified path
    # Store folder sizes in an associative array to print them ordered at the end
    local -A folder_size_map
    local -A reduced_folder_size_map
    local folder current_size
    while IFS= read -r -d '' folder; do
        current_size=$(du -s -- "$folder" 2>>"$err_output")
        current_size=${current_size%%[[:space:]]*}

        folder_size_map["$folder"]="$current_size"
        reduced_folder_size_map["$current_size"]="1" # Use the size as key to handle duplicates sizes
    done < <(find "$path" -mindepth 1 -maxdepth 1 -print0) # Use "find" instead of "ls" for safer and recursive file handling

    local current_folder_size=$(du -s -- "$path" 2>>"$err_output") # Get the size of the current folder to calculate percentages
    current_folder_size=${current_folder_size%%[[:space:]]*}

    folder_size_map["__CURRENT__"]="$current_folder_size"
    reduced_folder_size_map["$current_folder_size"]="1"

    # Order the folders by size, descending
    local folder_size_ordered="$(printf "%s\n" "${!reduced_folder_size_map[@]}"  | sort -n -r)"

    # Print the sizes in human-readable format, with percentages and visual bars
    local visual_percentage_length=20
    local size human_size percentage visual_percentage clean_folder i=0
    while read -r size; do
        human_size="$(human_readable_size "$size")"
        percentage=0
        ((current_folder_size > 0)) && percentage=$((size * 100 / current_folder_size))

        for folder in "${!folder_size_map[@]}"; do
            if [[ "${folder_size_map["$folder"]}" == "$size" ]]; then
                clean_folder="$(clean_folder_name "$folder")"
                visual_percentage=""
                [[ $folder != "__CURRENT__" ]] && visual_percentage="$(print_visual_percentage "$percentage" "$visual_percentage_length")"
                printf "%5s %$((visual_percentage_length+2))s (%3d%%) %s\n" "${human_size}" "$visual_percentage" "$percentage" "${clean_folder}"
                ((i++))
                if ((i >= max_results)); then
                    break 2
                fi
                unset "folder_size_map[$folder]" # Remove the folder from the map to handle duplicates sizes
            fi
        done
    done <<< "$folder_size_ordered"
}

function backupFileDate() {
    local filename=""
    local extension=".bkp"
    local append_date="false"
    local date_format="%Y.%m.%d-%H-%M-%S"
    local separator="-"

    # Parse named parameters
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -e=*|--extension=*)       extension="${1#*=}" ;;
            -d|--date)                append_date="true" ;;
            -df=*|--date-format=*)    date_format="${1#*=}"; append_date="true" ;;
            -s=*|--separator=*)       separator="${1#*=}" ;;
            -h|--help)
                echo "Usage: backupFileDate <filename> OPTIONS"
                echo " Backs up a file, optionally with a timestamp."
                echo ""
                echo " Parameters:"
                echo "   <filename>     Base name of the file (without extension)."
                echo " Options:"
                echo "   -e, --extension=STRING      Extension of the file. Default: .bkp"
                echo "   -d, --date                  Append the date in the backup file name"
                echo "   -df, --date-format=STRING   Format of the date. Automatically enables --date (Default: %Y.%m.%d-%H-%M-%S)"
                echo "   -s, --separator=STRING      Separator between filename and date. Only when using --date. Default: hyphen \"-\""
                echo ""
                echo " Example:"
                echo "   backupFileDate myfile.txt --date               Copy the file \"myfile.txt\" into \"myfile.txt.bkp\"-YYYY-MM-DD-HH-MM-SS"
                echo "   backupFileDate myfile.txt --extension=new      Copy the file \"myfile.txt\" into \"myfile.txt.new\""
                echo "   backupFileDate myfile.txt --date-format=%s     Creates a file named myfile.txt.bkp-123456789"
                return 0 ;;
            *) filename="$1" ;;
        esac
        shift
    done

    if [[ ! -f "${filename}" ]]; then
        echo "Error: File ${filename} doesn't exists"
        return 1
    fi
    
    if [[ ! -z "${extension}" && "${extension:0:1}" != "." ]] ; then
        extension=".${extension}"
    fi

    local date=""
    if [[ "${append_date}" == "true" ]]; then
        date="${separator}$(date +${date_format})"
    fi
    backup="${filename}${extension}$date"
    
    echo -e "Backing up ${filename} to ${backup}"
    cp --archive "${filename}" "${backup}"
}

# searchWord: Recursively find files containing a specific word.
# Usage: searchWord <word> [path]
#   - <word>: The word to search for.
#   - [path]: (optional) Directory to search in (default: current directory).
function searchWord() {
    local word="$1"
    local path="${2:-.}"  # If not path is provided, use current folder
    grep -rl "$word" "$path" 2>/dev/null
}

# field: Extracts a specific field (column <field>) from input data (multiple lines).
# Usage: field <field> [delimiter]
#   - <field>: The field number to extract (default: 1).
#   - [delimiter]: The delimiter used to separate fields (default: space).
# source : https://youtu.be/NE3ftNlfkdw?t=6122
function field() {
    awk -F "${2:- }" "{ print \$${1:-1} }"
}

# total: Sums up values in a specified field of input data.
# Usage: total <field> [delimiter]
#   - <field>: The field number to sum (default: 1).
#   - [delimiter]: The delimiter used to separate fields (default: space).
# source : https://youtu.be/NE3ftNlfkdw?t=6122
function total() {
    awk -F "${2:- }" "{ sum += \$${1:-1} } END { print sum }"
}

# print_array: Pretty print any arrays
# source : https://www.youtube.com/watch?v=jQ2IShKwtLA&t=2803s
function print_array() {
    local key value name
    for name in "$@"; do
        echo "${name}"
        echo "("
        eval "for key in \"\${!${name}[@]}\"; do
                value=\"\${${name}[\$key]}\"
                echo \"  [\$key] => \\\"\$value\\\"\"
              done"
        echo ")"
    done
}

# colorLogs: 
# Usage: colorLogs <path> [part] [partSize]
#   - <path>: The path to the log file
#   - [part]: Which part of the file to print
#           - head : print the top of the logs
#           - tail : print the end of the logs
#           - full : print all the logs
#           - less (default) : open the logs with "less" (usefull for huge logs)
#   - [partSize]: When used with part=head|tail : number of line to print
function colorLogs() {
    local path="$1"
    local part="$2"
    local partSize="$3"

    if [[ "${partSize}" =~ ^[0-9]+$ ]]; then
        partSize="-n ${partSize}"
    else
        partSize=""
    fi
    
    if [[ "${part}" == "head" ]]; then
        head "${path}" "${partSize}" | ccze -A
    elif [[ "${part}" == "tail" ]]; then
        tail "${path}" "${partSize}" | ccze -A
    elif [[ "${part}" == "full" ]]; then
        cat "${path}" | ccze -A
    else
        cat "${path}" | ccze -A | less -R
    fi
}

# mysqlconfig: Finds and displays MySQL configuration files (my.cnf).
#
# Behavior:
#   - Searches for my.cnf in a list of standard locations.
#   - By default, it prints the content of the first configuration file found.
#
# Options:
#   -a, --all:         Display the content of all found my.cnf files, not just the first one.
#   -c, --no-comment:  Remove comments and empty lines from the output.
#   -p, --no-print:    Only show the paths of found files without printing their content.
#
# Usage:
#   mysqlconfig              # Displays the first my.cnf file found.
#   mysqlconfig --all        # Displays all my.cnf files found.
#   mysqlconfig --no-comment # Displays the first my.cnf without comments.
#   mysqlconfig --all --no-print # Lists the paths of all found my.cnf files.
function mysqlconfig() {
    local show_all="false"
    local no_comments="false"
    local no_print="false"
    local files=(
        "/etc/my.cnf"
        "/etc/mysql/my.cnf"
        "/usr/local/etc/my.cnf"
        "/usr/bin/mysql/my.cnf"
        "$HOME/my.cnf"
        "$HOME/.my.cnf"
    )

    # Parse optional argument
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -a|--all) show_all="true" ;;
            -c|--no-comment) no_comments="true" ;;
            -p|--no-print) no_print="true" ;;
            *) echo "Unknown parameter ${1}" ;;
        esac
        shift
    done

    local found=0
    for f in "${files[@]}"; do
        if [ -f "${f}" ]; then
            echo "Found: ${f}"
            if [[ "${no_print}" == "false" && ("${show_all}" == "true" || "${found}" == "0") ]]; then
                if [[ "${no_comments}" == "true" ]]; then
                    cat "${f}" | grep -E '^[[:space:]]*[^[:space:]#]'
                else
                    cat "${f}"
                fi
                echo ""
            fi
            ((found++))
        fi
    done

    if [ ${found} -eq 0 ]; then
        echo "Error: my.cnf file could not be found."
        return 1
    fi
}

function createFileDate() {
    filename=""
    extension=""
    date_format="%F_%T"
    separator="_"

    # Parse named parameters
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -e=*|--extension=*)       extension="${1#*=}" ;;
            -df=*|--date-format=*)    date_format="${1#*=}" ;;
            -s=*|--separator=*)       separator="${1#*=}" ;;
            -h|--help)
                echo "Usage: createFileDate <filename> OPTIONS"
                echo " Creates an empty file with the current date and time in its name."
                echo ""
                echo " Parameters:"
                echo "   <filename>     Base name of the file (without extension)."
                echo " Options:"
                echo "   -e, --extension=STRING      Extension of the file. Default: none"
                echo "   -df, --date-format=STRING   Format of the date (Default: %F_%T)"
                echo "   -s, --separator=STRING      Separator between filename and date. Default: _"
                echo ""
                echo " Example:"
                echo "   createFileDate myfile --extension=txt      Creates a file named myfile_YYYY-MM-DD_HH:MM:SS.txt"
                echo "   createFileDate myfile --date-format=%s     Creates a file named myfile_123456789"
                echo "       "
                return 0 ;;
            *) filename="$1" ;;
        esac
        shift
    done
    
    if [[ -z "$filename" ]]; then
        echo "File name cannot be empty."
        echo "Usage: createFileDate <filename> OPTIONS)"
        echo "run with --help to see all options"
        return 1
    fi

    if [[ ! -z "${extension}" && "${extension:0:1}" != "." ]] ; then
        extension=".${extension}"
    fi

    timestamped_file="${filename}${separator}$(date +${date_format})${extension}"
    echo "Creating file: $timestamped_file"
    touch "$timestamped_file"
}

function renameFiles() {
    path="."
    search=" "
    replace="-"
    verbose="false"

    # Parse named parameters
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --path=*)      path="${1#*=}" ;;
            --search=*)    search="${1#*=}" ;;
            --replace=*)   replace="${1#*=}" ;;
            -v|--verbose)  verbose="true" ;;
            -h|--help)
                echo "Usage: renameFiles OPTIONS"
                echo ""
                echo "This function renames all files in the specified directory"
                echo "by replacing a string with another (default replace spaces with hyphens)"
                echo ""
                echo "Options:"
                echo "  --path=PATH         The path to the directory containing the files to be renamed. Default is current directory \".\""
                echo "  --search=STRING     The string to search for in file names. Default is a space \" \")."
                echo "  --replace=STRING    The string to replace the search string with. Default: is a hyphen \"-\")."
                echo "  --verbose, -v       Show unchanged files. Default: false"
                echo ""
                echo "Example:"
                echo "  renameFiles \"/home/user/documents\"  # Replaces spaces with hyphens in file names"
                echo "  renameFiles \"/home/user/documents\" \".jpeg\" \".jpg\"  # Replaces .jpeg by .jpg"
                return 0 ;;
            *) echo "❌ Unknown parameter: $1. Run with --help to see all options"; return 1 ;;
        esac
        shift
    done

    echo "Dir : $path, replacing '$search' with '$replace'"
    
    files_renamed=0
    for file in "$path"/*; do
        new_file="${file//$search/$replace}"
        if [[ -f "${new_file}" || -d "${new_file}" ]] ; then
            if [[ "${verbose}" == "true" ]] ; then
                echo "File ${new_file} already exist, skipping"
            fi
            continue
        fi
        echo "renaming : $file -> $new_file"
        mv "$file" "$new_file"
        files_renamed=$(($files_renamed + 1))
    done
    echo "--------"
    echo "${files_renamed} files renamed"
}

function convertWebpToJpg() {
    find . -type f -name "*.webp" -exec sh -c 'for file; do convert "$file" "${file%.webp}.jpg"; rm "$file"; done' _ {} +
}

# Jump into container as /bin/sh
function dockersh() {
    docker cp ~/.bashrc $1:/home/ || true
    docker exec -it $1 /bin/bash || docker exec -it $1 /bin/sh
}
function dcsh() {
    dockersh $1
}
# Print container logs
function dockerlogs() {
    docker logs -f $1
}
function dclogs() {
    dockerlogs $1
}

# Prints the OS users in a nice array
function prettyPrintUsers() {
    cat /etc/passwd| awk BEGIN{"FS=\":\""}{"printf \"| %-23s | %s | %8d  | %8d  |  %-43s | %-30s | %s\n\", \$1, \$2, \$3, \$4, \$5, \$6, \$7"}|sort -k6,6n
}

# Resizes all JPEG and PNG images in a specified directory to a given size.
#
# Parameters:
#   <path>   (Optional) Directory containing the images. Defaults to current directory ('.').
#   <size>   (Optional) Resize dimensions (e.g., 800x600). Defaults to '800x600'.
#
# Usage:
#   resizePictures <path> <size>
#
# Example:
#   resizePictures ./images 1024x768
#   Resizes all .jpg, .jpeg, and .png images in the ./images directory to 1024x768.
function resizePictures() {
    local path=${1:-.}
    local size=${2:-800x600}
    
    echo -e "Images found in \"${path}\" : " $(ls -1 ${path}/*.{jpg,jpeg,png} 2>/dev/null | wc -l)
    for img in ${path}/*.{jpg,jpeg,png}; do
        if [[ -f "${img}" ]] ; then
            convert "${img}" -resize $size "${img}" & echo "${img} resized"
        fi
    done
    
    if [[ -d ${path} ]] ; then
        nautilus ${path} &
    else
        echo "${path} is not a directory"
    fi
}

# Print the crontab of each user on this machine
function allCrontabs() {
    for user in $(cut -f1 -d: /etc/passwd); do
        if crontab -u "$user" -l 2>/dev/null | grep -q .; then
            echo "Crontab for user: $user"
            crontab -u "$user" -l
        fi
    done
}

# TODO Déplacer dans profile ?
function mountNetworkShares() {
    [[ -f ".bash.env" ]] && source .bash.env

    # Check if mount.cifs is installed
    if ! command -v mount.cifs &> /dev/null; then
        echo "mount.cifs is not installed. Please install cifs-utils package."
        echo "    sudo apt install cifs-utils"
        return 1
    fi
    
    # Mount commun
    if [[ -z "${MEDIA_BASE_PATH}" || -z "${COMMON_IP}" || -z "${COMMON_USERNAME}" || -z "${COMMON_PASSWORD}" ]]; then
        echo "Error: MEDIA_BASE_PATH, COMMON_IP, COMMON_USERNAME or COMMON_PASSWORD environment variables are not set."
    else
        sudo mkdir -p "${MEDIA_BASE_PATH}/${COMMON_NAME}"
        sudo mount -t cifs //${COMMON_IP}/Commun "${MEDIA_BASE_PATH}/${COMMON_NAME}" -o username=${COMMON_USERNAME},password=${COMMON_PASSWORD},rw,uid=1000,gid=1000
        echo -e "${COMMON_NAME} mounted at ${MEDIA_BASE_PATH}/${COMMON_NAME}"
        ls -alh "${MEDIA_BASE_PATH}/${COMMON_NAME}"
    fi

    # Mount TV
    if [[ -z "${MEDIA_BASE_PATH}" || -z "${TV_IP}" || -z "${TV_USERNAME}" || -z "${TV_PASSWORD}" ]]; then
        echo "Error: MEDIA_BASE_PATH, TV_IP, TV_USERNAME or TV_PASSWORD environment variables are not set."
    else
        sudo mkdir -p "${MEDIA_BASE_PATH}/${TV_NAME}"
        sudo mount -t cifs //${TV_IP}/TV "${MEDIA_BASE_PATH}/${TV_NAME}" -o username="${TV_USERNAME}",password="${TV_PASSWORD}",rw,uid=1000,gid=1000
        echo -e "\n${TV_NAME} mounted at ${MEDIA_BASE_PATH}/${TV_NAME}"
        ls -alh "${MEDIA_BASE_PATH}/${TV_NAME}"
    fi

    # Open file manager
    echo -e "Opening file manager and exiting"
    nautilus "${MEDIA_BASE_PATH}" &
    cd "${MEDIA_BASE_PATH}"
}

# syncMyCloud: Synchronizes files from a remote server to the local machine.
# TODO delete ? I now use git to sync my cloud
#
# Behavior:
#   - Uses scp to recursively copy files from a predefined remote directory
#     on 'pumbaa.ch' to the local '~/mycloud/' directory.
#   - Connection details (port, user, server, paths) are hardcoded within the function.
#
# Usage:
#   syncMyCloud
function syncMyCloud() {
    [[ -f ".bash.env" ]] && source .bash.env
    scp -r -P $VPS_SCP_PORT "$VPS_SCP_USER"@"$VPS_SCP_SERVER":"$VPS_DISTANT_PATH" "$VPS_LOCAL_PATH"
}

function git_diff() {
    local source_branch=""
    local target_branch=""
    local usage="Usage: git_diff [<branch1> [<branch2>]]
    
    Shows the git diff between two branches using 'git difftool', itself configurable (i.e. default editor).

    If no branches are provided, it uses the current branch and 'main' as target.
    If one branch is provided, it uses it as source and 'main' as target.
    If two branches are provided, it uses them as source and target respectively.
    You can also provide a single argument in the form 'branch1..branch2' to specify both branches.
    
    Run 'git_diff help' to see this message."

    # More than 2 arguments are not supported
    if [ "$#" -gt 2 ]; then
        echo -e "$usage"
        return 1
    fi

    # 2 args : Normal way
    if [ "$#" -eq 2 ]; then
        source_branch="$1"
        target_branch="$2"
    fi

    # 1 arg : try to split it on space or ..
    if [ "$#" -eq 1 ]; then
        if [[ "$1" == *"help" ]]; then
            echo -e "$usage"
            return 0
        elif [[ "$1" == *".."* ]]; then
            source_branch="${1%%..*}"
            target_branch="${1##*..}"
        else
            source_branch="$1"
            target_branch="main"
        fi
    fi

    # No args : use current branch and main
    if [ "$#" -eq 0 ]; then
        source_branch="$(git rev-parse --abbrev-ref HEAD)"
        target_branch="main"
    fi

    # Finally show the diff !
    echo -e "Showing git diff between ${BOLD}${source_branch}${RESET} and ${BOLD}${target_branch}${RESET}"
    git difftool --dir-diff "$source_branch..$target_branch" & 
}

# Check if the machine name is my development machine
# and load custom dev-env config
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
if [ "$HOSTNAME" = "ENG-0014" ]; then
    GREEN='\033[7;32m'
    NC='\033[0m' # No Color
    echo -e "Welcome to your development machine ${GREEN}$USER${NC}, loading your custom configuration..."
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

RESET='\033[0m'
BOLD_YELLOW='\033[1;33m'
echo -e "Custom bashrc loaded"
echo -e "run ${BOLD_YELLOW}myHelp${RESET} to show aliases and functions"



################################################
#                 EEProperty                   #
################################################
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
export PATH="$PATH:$JAVA_HOME"
export PATH="$PATH:/snap/intellij-idea-community/current/bin"

# Function: sqlite3_export_table
# Description:
#   This function exports the contents of a SQLite table to a .sql file using the specified export mode.
#
# Parameters:
#   $1 : file (Required)   - Path to the SQLite database
#   $2 : table (Required)  - Name of the table to export
#   $3 : mode (Optional)   - SQLite export mode (e.g., insert, csv, json, table, etc.). Default: insert.
#
# Usage:
#   export_table <file> <table> [mode]
#
# Prerequisites:
#   - The sqlite3 command must be installed and available in the PATH.
#   - The SQLite database file must exist and be readable.
function sqlite3_export_table() {
    # Check the parameters
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: sqlite3_export_table <file> <table> [mode]"
        return 1
    fi

    local file="$1"
    local table="$2"
    local mode="${3:-insert}" # Mode par défaut : insert

    # Check the sqlite file existe and is readable
    if [ ! -f "$file" ]; then
        echo "Error : The file '$file' doesn't exist"
        return 1
    fi

    # Export the table
    sqlite3 "$file" ".mode $mode $table" "SELECT * FROM $table;" > "${table}.sql"

    if [ $? -eq 0 ]; then
        echo "Export table '$table' with mode '$mode' done : ${table}.sql"
    else
        echo "Error while exporting table '$table'."
        return 1
    fi
}

function sqlite3_export_db() {
    # Check the parameters
    if [ -z "$1" ] ; then
        echo "Usage: sqlite3_export_db <file>"
        return 1
    fi

    local file="$1"
    local extension="sql"
    local timestamped_file="${file}_$(date +%F_%T).${extension}"

    # Check the sqlite file existe and is readable
    if [ ! -f "$file" ]; then
        echo "Error : The file '$file' doesn't exist"
        return 1
    fi

    # Export the table
    sqlite3 "$file" .dump > $timestamped_file


    if [ $? -eq 0 ]; then
        echo "Export database done : $timestamped_file"
    else
        echo "Error while exporting database '$file'."
        return 1
    fi
}

function countFiles() {
# alias lx='for folder in $(ls -A) ; do du -hs "$folder" ; done ; du -hs'

    SHOW_DETAIL="false"
    DIR_PATH="."

    # Parse command-line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d|--detail)        SHOW_DETAIL="true";;
            -*)                 echo "Unknown parameter $1";;
            *)                  DIR_PATH=$1;;
        esac
        shift
    done

    # Check directory path existence
    if [[ -z "${DIR_PATH}" ]]; then
        echo "Usage: countFiles [OPTIONS] <directory_path>"
        echo "  Options : "
        echo "    -d,--detail   Show file count for each subfolders in addition to total"
        return 1
    fi

    if [[ ! -d "${DIR_PATH}" ]]; then
        echo "Error: '${DIR_PATH}' is not a valid directory."
        return 1
    fi

    # Recursively show countFile for subfolders
    if [[ "${SHOW_DETAIL}" == "true" ]]; then
        echo "Number of files in subfolders of ${DIR_PATH} : "
        total=0
        for dir in "${DIR_PATH}"/*; do
            if [[ ! -d "${dir}" ]]; then continue; fi
            count=$(countFiles "${dir}")
            echo "${dir} : ${count}"
            total=$((total + count))
        done
        
        echo "Sum of subfolders: ${total}"
        #return 0
    fi

    # TODO compter le nombre de fichiers uniquement à la racine de $1 et l'ajouter au $total et décommenter le return 0
    # printf "Total files in %s: \n" "$DIR_PATH"
    TOTAL=$(find "$DIR_PATH" -type f | wc -l)
    echo $TOTAL
    return $TOTAL
}

# Flipper Zero
eval "$(register-python-argcomplete pipx)"
# End Flipper Zero

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
# Created by `pipx` on 2025-06-18 15:57:20
export PATH="$PATH:/home/lcorrevon/.local/bin"
export PATH="$PATH:/home/lcorrevon/programmation/perso/bash/"
export PATH="$PATH:/home/lcorrevon/programmation/perso/bash/lsix"

# pnpm
export PNPM_HOME="/home/lcorrevon/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH=/home/lcorrevon/.opencode/bin:$PATH
