# Server Performance Analysis Script

A comprehensive Bash script to analyze and report basic server performance statistics. This tool provides a quick snapshot of a Linux server's health, including CPU, memory, disk usage, and more.

## Project URL

https://roadmap.sh/projects/server-stats

## Features

This script reports on the following metrics:

### Core Requirements
- **Total CPU Usage**: Current CPU utilization percentage.
- **Total Memory Usage**: Breakdown of total, used, and free memory with usage percentage.
- **Total Disk Usage**: Used vs. free space for all mounted filesystems.
- **Top 5 Processes by CPU**: Lists the processes consuming the most CPU resources.
- **Top 5 Processes by Memory**: Lists the processes consuming the most memory.

### Stretch Goals
- **OS Version**: Displays the operating system's name and version.
- **Uptime**: Shows how long the server has been running.
- **Load Average**: Displays the 1, 5, and 15-minute load averages.
- **Logged in Users**: Lists all users currently logged into the server.
- **Failed Login Attempts**: Counts recent failed login attempts from system logs.

## Requirements

This script uses standard Linux command-line utilities that are typically pre-installed on most distributions. It requires:
- `bash`
- `bc` (for floating-point calculations)
- Standard coreutils (`top`, `free`, `df`, `ps`, `who`, `grep`, `awk`, `sed`, `cut`)

## How to Use

1.  **Clone the repository**
    ```bash
    git clone https://github.com/back2bram/server-stats.git
    cd server-stats
    ```

2.  **Make the script executable**
    ```bash
    chmod +x server-stats.sh
    ```

3.  **Run the script**
    ```bash
    ./server-stats.sh
    ```
    **Note**: For the "Failed Login Attempts" feature, you may need to run the script with `sudo` if your user doesn't have permission to read `/var/log/auth.log` or `/var/log/secure`.
    ```bash
    sudo ./server-stats.sh
    ```

## Sample Output

## Contributing

Feel free to submit issues or pull requests to improve this script!
