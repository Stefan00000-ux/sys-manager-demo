#!/bin/bash
# sys_manager.sh - Modular system/user management script
# Author: Stephen
# Date: 2025-10-16

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# -----------------------------
# Function: Add multiple users
# -----------------------------
add_users() {
    local file="$1"
    [[ ! -f $file ]] && { echo -e "${RED}User file not found: $file${RESET}"; exit 1; }

    while read -r user; do
        if id "$user" &>/dev/null; then
            echo -e "${YELLOW}Already exists: $user${RESET}"
        else
            sudo useradd -m "$user" && echo -e "${GREEN}Created user: $user${RESET}"
        fi
    done < "$file"
}

# -----------------------------
# Function: Setup project folders
# -----------------------------
setup_projects() {
    local user="$1"
    local n="$2"
    local base="/home/$user/projects"

    [[ ! -d /home/$user ]] && { echo -e "${RED}User $user home not found${RESET}"; exit 1; }

    mkdir -p "$base"
    for i in $(seq 1 $n); do
        dir="$base/project$i"
        mkdir -p "$dir"
        echo "Project project$i created on $(date) by $user" > "$dir/README.txt"
        chmod 755 "$dir"
        chmod 640 "$dir/README.txt"
        chown -R "$user:$user" "$dir"
        echo -e "${GREEN}Created: $dir${RESET}"
    done
}

# -----------------------------
# Function: System report
# -----------------------------
sys_report() {
    local outfile="$1"
    {
        echo "Disk Usage:"; df -h
        echo -e "\nMemory Info:"; free -h
        echo -e "\nCPU Info:"; lscpu | grep -E 'Model|CPU\(s\)|Thread'
        echo -e "\nTop 5 Memory-consuming processes:"; ps -eo pid,comm,%mem --sort=-%mem | head -n 6
        echo -e "\nTop 5 CPU-consuming processes:"; ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
    } > "$outfile"
    echo -e "${GREEN}System report saved to $outfile${RESET}"
}

# -----------------------------
# Function: Process management
# -----------------------------
process_manage() {
    local user="$1"
    local action="$2"

    case "$action" in
        list_zombies)
            ps -u "$user" -o pid,stat,comm | awk '$2=="Z"'
            ;;
        list_stopped)
            ps -u "$user" -o pid,stat,comm | awk '$2=="T"'
            ;;
        kill_zombies)
            echo -e "${YELLOW}Cannot kill zombie processes directly${RESET}"
            ;;
        kill_stopped)
            pids=$(ps -u "$user" -o pid,stat,comm | awk '$2=="T"{print $1}')
            [[ -z $pids ]] && echo "No stopped processes" || sudo kill -9 $pids && echo -e "${GREEN}Stopped processes killed${RESET}"
            ;;
        *)
            echo -e "${RED}Invalid action: $action${RESET}"; exit 1
            ;;
    esac
}

# -----------------------------
# Function: Permissions & ownership
# -----------------------------
perm_owner() {
    local user="$1"
    local path="$2"
    local perms="$3"
    local owner="$4"
    local group="$5"

    [[ ! -d $path ]] && { echo -e "${RED}Path not found: $path${RESET}"; exit 1; }
    sudo chown -R "$owner:$group" "$path"
    sudo chmod -R "$perms" "$path"
    echo -e "${GREEN}Permissions & ownership updated for $path${RESET}"
}

# -----------------------------
# Function: Help menu
# -----------------------------
help_menu() {
    cat <<EOF
Usage: $0 <mode> [args]

Modes:
  add_users <file>
  setup_projects <username> <number>
  sys_report <output_file>
  process_manage <username> <action>
  perm_owner <username> <path> <permissions> <owner> <group>
  help

EOF
}

# -----------------------------
# Main argument parsing
# -----------------------------
[[ $# -lt 1 ]] && { help_menu; exit 1; }

case "$1" in
    add_users) add_users "$2" ;;
    setup_projects) setup_projects "$2" "$3" ;;
    sys_report) sys_report "$2" ;;
    process_manage) process_manage "$2" "$3" ;;
    perm_owner) perm_owner "$2" "$3" "$4" "$5" "$6" ;;
    help) help_menu ;;
    *) echo -e "${RED}Unknown mode: $1${RESET}"; help_menu; exit 1 ;;
esac

exit 0

