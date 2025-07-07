# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
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

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# echo "color_prompt : $color_prompt"/usr/lib/jvm/java-21-openjdk-amd64/bin/java
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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
# alias l='ls -CF'

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
fortune -a | cowsay -f $(shuf -n1 -e hellokitty default tux moose)

alias l='ls -alh'
alias lg='ls -alh | grep -i $1'
alias lx='folderSize'
alias vscode='code'
alias kb-enable='~/programmation/perso/bash/toggle_keyboard.sh --enable'
alias kb-disable='~/programmation/perso/bash/toggle_keyboard.sh --disable'
alias flipper='/opt/flipper-zero/AppRun'

myHelp()
{
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
    
    echo -e "${GREEN}# Aliases${RESET}"
    echo -e "${CYAN}l${RESET} ${ITALIC}ls -alh${RESET}\t\t\tPrints files list with human readable sizes"
    echo -e "${CYAN}lg${RESET} ${ITALIC}ls -alh | grep -i \$1${RESET}\t\tSearch a filename in the current directory"
    echo -e "${CYAN}lx${RESET} ${ITALIC}folderSize${RESET}\t\t\tShows directory size recursively"
    echo -e "${CYAN}code${RESET} ${ITALIC}vscode${RESET}\t\t\tLaunch Microsoft VSCode, code editor"
    echo -e "${CYAN}kb-enable${RESET} ${ITALIC}enable_keyboard.sh${RESET}\tEnable the built-in (laptop) keyboard"
    echo -e "${CYAN}kb-disable${RESET} ${ITALIC}disable_keyboard.sh${RESET}\tDisable the built-in (laptop) keyboard"
    echo -e ""
    
    echo -e "${GREEN}# Files and pictures${RESET}"
    
    echo -e "${BOLD_YELLOW}folderSize(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\tRecursively show the size of a folder and its subfolders"
    echo -e "${BOLD_YELLOW}countFiles(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\tRecursively count the number of regular files in a folder"
    echo -e "${BOLD_YELLOW}mygrep(${YELLOW}${ITALIC}search_patern${BOLD_YELLOW})${RESET}\t\tPretty grep"
    echo -e "${BOLD_YELLOW}chownwww(${YELLOW}${ITALIC}path${BOLD_YELLOW})${RESET}\t\t\tApplies www-data user and group to a file or directory, recursively"

    echo -e "${BOLD_YELLOW}createFileDate(${YELLOW}${ITALIC}name, ext${BOLD_YELLOW})${RESET}\tCreates an empty file with the current date and time in its name"
    echo -e "${BOLD_YELLOW}backupFileDate(${YELLOW}${ITALIC}name${BOLD_YELLOW})${RESET}\t\tBacks up a file, optionally with a timestamp"
    echo -e "${BOLD_YELLOW}renameFiles(${YELLOW}${ITALIC}path,search,replace${BOLD_YELLOW})${RESET}Renames all files in the specified directory"
    echo -e "${BOLD_YELLOW}resizePictures(${YELLOW}${ITALIC}path, size${BOLD_YELLOW})${RESET}\tResizes all images in a directory"
    echo -e "${BOLD_YELLOW}searchWord(${YELLOW}${ITALIC}word, (path)${BOLD_YELLOW})${RESET}\tShows files where the word appears"
    echo -e ""

    echo -e "${GREEN}# Docker${RESET}"
    echo -e "${BOLD_YELLOW}dockersh(${YELLOW}${ITALIC}container_name${RESET}${BOLD_YELLOW})${RESET}\tJumps into container as /bin/sh"
    echo -e "\t${BOLD_YELLOW}dcsh(${YELLOW}${ITALIC}container_name${BOLD_YELLOW})${RESET}"
    echo -e "${BOLD_YELLOW}dockerlogs(${YELLOW}${ITALIC}container_name${RESET}${BOLD_YELLOW})${RESET}\tPrints container logs"
    echo -e "\t${BOLD_YELLOW}dclogs(${YELLOW}${ITALIC}container_name${BOLD_YELLOW})${RESET}"
    echo -e ""
    
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

# Remove all old kernels except the current one
# The upgrade needs a total of XXX M free space on disk '/boot'. Please free at least an additional XXX M of disk space on '/boot'
# https://gist.github.com/harshalbhakta/887e4521a1043d36979b
clearBoot()
{
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
}

# Apply www-data user and group to a file or directory, recursively
# I made a function instead of an alias because I couldn't pass an alias to sudo
# https://superuser.com/questions/1220872/how-can-i-pass-an-alias-to-sudo
chownwww()
{
    sudo chown -R www-data:www-data $*
}

# Grep lisible
# source : http://doc.ubuntu-fr.org/alias
mygrep()
{
    local word="$1"
    local path="${2:-.}"  # If not path is provided, use current folder
	grep -Rins --color -A 5 -B 5 $word $path
}

# Show the size of a folder and its subfolders
#
# Arguments:
#   $1 - Path to the folder to analyze. If not provided, defaults to the current directory.
#   $2 - Optional: File or file descriptor where error messages should be redirected.
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
#   folderSize PATH /dev/stderr     # Show size of PATH folder and subfolder and print errors
#
# Originaly written as a simple alias
#   alias lx='for folder in $(ls -A) ; do du -hs "$folder" ; done ; du -hs'
# Source : http://www.linuxquestions.org/questions/linux-general-1/cmdline-howto-know-size-of-folder-recursive-569884/
folderSize() {
    local path="${1:-.}"  # Default to current directory if no path is provided
    local err_output="${2:-/dev/null}"  # Error output. Default to /dev/null to get rid of unwanted message

    # Use "find" instead of "ls" for safer and recursive file handling
    while IFS= read -r -d '' folder; do
        du -hs "$folder" 2>>"$err_output"
    done < <(find "$path" -mindepth 1 -maxdepth 1 -print0)

    du -hs "$path" 2>>"$err_output"
}

# Backs up a file, optionally with a timestamp.
#
# Arguments:
#   $1 - File to back up. If the file doesn't exist, an error is shown.
#   $2 - Optional: "-d" or "--date" to append a timestamp (format: YYYY.MM.DD-HH-MM-SS).
#
# Behavior:
#   - If the file exists, it creates a backup with or without a timestamp.
#   - Uses "cp --archive" to preserve file attributes.
backupFileDate()
{
    file="$1"

    if [ ! -f "${file}" ]; then
        echo "Erreur: Le fichier ${file} n'existe pas"
    else
        if [[ "$2" == "-d" || "$2" == "--date" ]]; then
            backup="${file}.bkp-$(date +"%Y.%m.%d-%H-%M-%S")"
        else
            backup="${file}.bkp"
        fi
        
        echo -e "Backing up ${file} to ${backup}"
        cp --archive "${file}" "${backup}"
    fi
}

# search_word: Recursively find files containing a specific word.
# Usage: search_word <word> [path]
#   - <word>: The word to search for.
#   - [path]: (optional) Directory to search in (default: current directory).
searchWord() {
    local word="$1"
    local path="${2:-.}"  # If not path is provided, use current folder
    grep -rl "$word" "$path" 2>/dev/null
}

# Creates an empty file with the current date and time in its name.
#
# Parameters:
#   <filename>     Base name of the file (without extension).
#   <extension>    Extension of the file.
#   <date format>  Optional. Format of the date (Default: %F_%T)
#
# Usage:
#   createFileDate <filename> <extension>
#
# Example:
#   createFileDate myfile txt
#   Creates a file named myfile_YYYY-MM-DD_HH:MM:SS.txt
createFileDate() {
    filename="$1"
    extension="$2"
    date_format=${3:-%F_%T}
    
    if [ -z "$filename" ] || [ -z "$extension" ]; then
        echo "Usage: createFileDate <filename> <extension>"
    else
        timestamped_file="${filename}_$(date +${date_format}).${extension}"
        echo "Creating file: $timestamped_file"
        touch "$timestamped_file"
    fi
}

# This function renames all files in the specified directory
# by replacing a string with another (default replace spaces with hyphens)
#
# Parameters:
#   $1 - The path to the directory containing the files to be renamed.
#   $2 - The string to search for in file names (optional, default is a space " ").
#   $3 - The string to replace the search string with (optional, default is a hyphen "-").
#
# Example:
#   renameFiles "/home/user/documents"  # Replaces spaces with hyphens in file names
#   renameFiles "/home/user/documents" "_" "+"  # Replaces underscores with plus signs
renameFiles()
{
    path=$1
    search="${2:- }"
    replace="${3:--}"
    echo "Dir : $path, replacing '$search' with '$replace'"
    
    for file in "$path"/*; do
        new_file="${file//$search/$replace}"
        echo "renaming : $file -> $new_file"
        mv "$file" "$new_file"
    done
    echo -e "--------\ndone"
}

# Jump into container as /bin/sh
dockersh()
{
    docker cp ~/.bashrc $1:/root/ || true
    docker exec -it $1 /bin/bash || docker exec -it $1 /bin/sh
}
dcsh()
{
    dockersh $1
}
# Print container logs
dockerlogs()
{
    docker logs -f $1
}
dclogs()
{
    dockerlogs $1
}

# Prints the OS users in a nice array
prettyPrintUsers()
{
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
resizePictures()
{
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
allCrontabs()
{
    for user in $(cut -f1 -d: /etc/passwd); do
        if crontab -u "$user" -l 2>/dev/null | grep -q .; then
            echo "Crontab for user: $user"
            crontab -u "$user" -l
        fi
    done
}

# TODO Déplacer dans profile ?
mountNetworkShares()
{
    username="loic"
    password=""
    mediaBasePath="/media/$username"
    commun="commun"
    tv="tv"
    
    sudo mount -t cifs //192.168.10.100/Commun $mediaBasePath/$commun -o username=$username,password=$password,rw,uid=1000,gid=1000
    echo -e "Commun mounted at $mediaBasePath/$commun"
    ls -alh $mediaBasePath/$commun
    
    sudo mount -t cifs //192.168.10.107/TV $mediaBasePath/$tv -o username=mosivon,password=
    echo -e "\nTV mounted at $mediaBasePath/$tv"
    ls -alh $mediaBasePath/$tv
    
    echo -e "Opening file manager and exiting"
    nautilus $mediaBasePath &
}

syncMyCloud()
{
    scpPort="18592"
    scpUser="pumbaa"
    scpServer="pumbaa.ch"
    distantPath="~/mycloud/divers/"
    localPath="/home/lcorrevon/mycloud/"

    scp -r -P $scpPort $scpUser@$scpServer:$distantPath $localPath
    #scp -r -P 18592 pumbaa@pumbaa.ch:~/mycloud/divers /home/lcorrevon/mycloud/
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
sqlite3_export_table() {
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

sqlite3_export_db() {
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

countFiles() {
# alias lx='for folder in $(ls -A) ; do du -hs "$folder" ; done ; du -hs'

    SHOW_DETAIL="false"
    DIR_PATH=""

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
