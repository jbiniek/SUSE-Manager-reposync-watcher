#!/bin/bash

# Clear the screen completely on startup
printf "\033[2J"

# Initialize spinner characters
SPINNER_CHARS=('|' '/' '-' '\')
SPINNER_IDX=0

while true; do
    # 1. Fetch all data in the background FIRST
    DISK_USAGE=$(df /var/lib/containers/storage/volumes 2>/dev/null | awk 'NR==2 {print $5}')
    
    # Strip the '%' sign to get the raw number for comparison
    DISK_NUM="${DISK_USAGE%%%}"
    
    if [ -z "$DISK_USAGE" ] || [[ ! "$DISK_NUM" =~ ^[0-9]+$ ]]; then 
        DISK_USAGE="N/A"
        DISK_COLOR="\e[0m" # Default color
    elif [ "$DISK_NUM" -lt 60 ]; then
        DISK_COLOR="\e[32m" # Green
    elif [ "$DISK_NUM" -lt 80 ]; then
        DISK_COLOR="\e[33m" # Yellow
    else
        DISK_COLOR="\e[31m" # Red
    fi

    # Find the active log path
    RELATIVE_LOG_PATH=$(mgrctl exec -- tail -n 50 /var/log/rhn/reposync.log 2>/dev/null | grep "Please check" | tail -n 1 | awk -F"'" '{print $2}')
    
    if [ -n "$RELATIVE_LOG_PATH" ]; then
        FULL_LOG_PATH="/var/log/rhn/$RELATIVE_LOG_PATH"
        # Fetch the last 10 rolling lines
        LOG_LINES=$(mgrctl exec -- tail -n 10 "$FULL_LOG_PATH" 2>/dev/null)
        # Fetch up to 10 most recent error lines from the current log
        ERROR_LINES=$(mgrctl exec -- grep "ERROR:" "$FULL_LOG_PATH" 2>/dev/null | tail -n 10)
    else
        FULL_LOG_PATH="No active sync log found."
        LOG_LINES=""
        ERROR_LINES=""
    fi

    # Find the PID of the active sync process inside the container
    SYNC_PID=$(mgrctl exec -- ps -ef 2>/dev/null | grep "[s]pacewalk-repo-sync" | awk '{print $2}' | head -n 1)
    if [ -n "$SYNC_PID" ]; then
        ABORT_CMD="mgrctl exec -- kill -9 $SYNC_PID"
    else
        ABORT_CMD="N/A (No active sync process detected)"
    fi

    # Update spinner state
    SPINNER="${SPINNER_CHARS[$SPINNER_IDX]}"
    SPINNER_IDX=$(( (SPINNER_IDX + 1) % 4 ))

    # 2. Instantly update the screen
    # Move cursor to top-left
    printf "\033[H"
    
    # Print the header using -e to enable escape codes, and \033[K to erase remnant text
    echo -e "==========================================================================\033[K"
    echo -e "Activity:                 [ $SPINNER ]\033[K"
    echo -e "Volume Usage:             ${DISK_COLOR}${DISK_USAGE}\e[0m\033[K"
    echo -e "Following active sync log: $FULL_LOG_PATH\033[K"
    echo -e "Abort current sync:       $ABORT_CMD\033[K"
    echo -e "Press [Ctrl+C] to stop.\033[K"
    echo -e "==========================================================================\033[K"
    
    # Print sticky errors in RED if any exist
    if [ -n "$ERROR_LINES" ]; then
        echo -e "\e[31m--- Recent Errors ---\e[0m\033[K"
        echo "$ERROR_LINES" | while IFS= read -r line; do
            # Wrap the line in red escape codes and clear the rest of the line
            echo -e "\e[31m${line}\e[0m\033[K"
        done
        echo -e "\e[31m--------------------------------------------------------------------------\e[0m\033[K"
    fi

    # Print the standard rolling logs
    if [ -n "$LOG_LINES" ]; then
        echo "$LOG_LINES" | while IFS= read -r line; do
            echo -e "${line}\033[K"
        done
    fi

    # Erase any leftover lines below the logs
    printf "\033[0J"

    # 3. Pause before next cycle
    sleep 2
done
