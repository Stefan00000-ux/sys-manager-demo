#!/bin/bash
# Demo runner for sys_manager.sh - runs all functions sequentially

SCRIPT="./sys_manager.sh"
USER_FILE="usernames.txt"
PROJECT_USER="alex"
NUM_PROJECTS=3
REPORT="/tmp/sys_report.txt"

# 1) Sample usernames file
echo -e "alex\nmike\njohn" > $USER_FILE
echo -e "\n--- Step 1: add_users ---"
sudo $SCRIPT add_users $USER_FILE | tee add_users_out.txt

# 2) Setup projects
echo -e "\n--- Step 2: setup_projects ---"
sudo $SCRIPT setup_projects $PROJECT_USER $NUM_PROJECTS | tee setup_projects_out.txt
sudo cat /home/$PROJECT_USER/projects/project1/README.txt | tee readme_preview.txt

# 3) System report
echo -e "\n--- Step 3: sys_report ---"
$SCRIPT sys_report $REPORT | tee sys_report_run.txt
sed -n '1,40p' $REPORT | tee sys_report_excerpt.txt

# 4) Process management demo
echo -e "\n--- Step 4: process_manage ---"
/bin/sleep 1000 & PID=$!
kill -SIGSTOP $PID
$SCRIPT process_manage $(whoami) list_stopped | tee process_list_stopped.txt
sudo $SCRIPT process_manage $(whoami) kill_stopped | tee process_kill_stopped.txt
kill -9 $PID 2>/dev/null || true

# 5) Permissions & ownership
echo -e "\n--- Step 5: perm_owner ---"
sudo $SCRIPT perm_owner $PROJECT_USER /home/$PROJECT_USER/projects 755 $PROJECT_USER $PROJECT_USER | tee perm_owner_out.txt

# 6) Help menu
echo -e "\n--- Step 6: help ---"
$SCRIPT help | tee help_out.txt

echo -e "\n=== Demo complete! Check *.txt files for outputs ==="

