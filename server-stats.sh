#!/bin/bash

# server-stats.sh
# A script to analyze and report basic server performance statistics.

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# --- Core Analysis Functions ---

# Function to get total CPU usage
get_cpu_usage() {
    # Uses 'top' in batch mode for one iteration, then parses the idle percentage.
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print $1}')
    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
    echo -e "${YELLOW}Total CPU Usage: ${CPU_USAGE}%${NC}"
}

# Function to get total memory usage
get_memory_usage() {
    # Uses 'free' to get memory info in megabytes.
    MEMORY_INFO=$(free -m | grep "Mem:")
    TOTAL_MEM=$(echo $MEMORY_INFO | awk '{print $2}')
    USED_MEM=$(echo $MEMORY_INFO | awk '{print $3}')
    FREE_MEM=$(echo $MEMORY_INFO | awk '{print $4}')
    # 'bc' is used for floating point arithmetic to calculate the percentage.
    PERCENTAGE_USED=$(echo "scale=2; $USED_MEM / $TOTAL_MEM * 100" | bc)
    
    echo -e "${YELLOW}Memory Usage:${NC}"
    echo -e "  Total: ${TOTAL_MEM}MB"
    echo -e "  Used:  ${USED_MEM}MB (${PERCENTAGE_USED}%)"
    echo -e "  Free:  ${FREE_MEM}MB"
}

# Function to get total disk usage
get_disk_usage() {
    echo -e "${YELLOW}Disk Usage:${NC}"
    # 'df -h' provides human-readable sizes. We filter out temporary filesystems.
    df -h | grep -vE '^Filesystem|tmpfs|udev' | awk '{print "  " $1 " -> " $3 " / " $2 " (" $5 " used)"}'
}

# Function to get top 5 processes by CPU usage
get_top_cpu_processes() {
    echo -e "${YELLOW}Top 5 Processes by CPU Usage:${NC}"
    # 'ps' is used to list all processes with specific columns, sorted by CPU usage.
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6 | awk 'NR==1 {print "  " $0} NR>1 {printf "  %-6s %-6s %-30s %s%% %s%%\n", $1, $2, $3, $4, $5}'
}

# Function to get top 5 processes by Memory usage
get_top_memory_processes() {
    echo -e "${YELLOW}Top 5 Processes by Memory Usage:${NC}"
    # Similar to the CPU function, but sorted by memory usage.
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6 | awk 'NR==1 {print "  " $0} NR>1 {printf "  %-6s %-6s %-30s %s%% %s%%\n", $1, $2, $3, $4, $5}'
}

# --- Stretch Goal Functions ---

# Function to get OS version
get_os_info() {
    # Reads from /etc/os-release for a clean OS name, with 'uname' as a fallback.
    if [ -f /etc/os-release ]; then
        OS_INFO=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
    else
        OS_INFO=$(uname -a)
    fi
    echo -e "${YELLOW}OS Version: ${OS_INFO}${NC}"
}

# Function to get system uptime and load average
get_uptime_load() {
    # 'uptime -p' gives a pretty format, but isn't universal. 'uptime' is the fallback.
    UPTIME_PRETTY=$(uptime -p 2>/dev/null)
    if [ $? -eq 0 ]; then
        UPTIME=$UPTIME_PRETTY
    else
        UPTIME=$(uptime | awk '{print $3,$4}' | cut -d ',' -f1)
    fi
    LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }')
    echo -e "${YELLOW}Uptime: ${UPTIME}${NC}"
    echo -e "${YELLOW}Load Average: ${LOAD_AVG}${NC}"
}

# Function to get logged in users
get_logged_users() {
    USER_COUNT=$(who | wc -l)
    echo -e "${YELLOW}Logged in Users (${USER_COUNT}):${NC}"
    who | awk '{print "  - " $1 " (" $2 ") on " $3 " " $4}'
}

# Function to get failed login attempts
get_failed_logins() {
    FAILED_COUNT=0
    LOG_FILE=""
    # Checks for common log file locations.
    if [ -f /var/log/auth.log ]; then
        LOG_FILE="/var/log/auth.log"
    elif [ -f /var/log/secure ]; then
        LOG_FILE="/var/log/secure"
    fi

    if [ -n "$LOG_FILE" ]; then
        # Requires sudo to read on many systems.
        FAILED_COUNT=$(sudo grep "Failed password" $LOG_FILE | wc -l)
        echo -e "${YELLOW}Failed Login Attempts (from ${LOG_FILE##*/}): ${FAILED_COUNT}${NC}"
    else
        echo -e "${YELLOW}Failed Login Attempts: Log file not found or inaccessible.${NC}"
    fi
}


# --- Main Execution Function ---
main() {
    clear
    echo -e "${GREEN}Server Performance Analysis Report${NC}"
    echo -e "${GREEN}Generated on: $(date)${NC}"
    
    print_header "System Information"
    get_os_info
    get_uptime_load
    
    print_header "Resource Usage"
    get_cpu_usage
    get_memory_usage
    get_disk_usage
    
    print_header "Process Information"
    get_top_cpu_processes
    get_top_memory_processes
    
    print_header "Security Information"
    get_logged_users
    get_failed_logins
    
    echo -e "\n${GREEN}Report generation completed.${NC}"
}

# Execute the main function
main
