#!/bin/bash

while true; do      echo "$(date '+%Y-%m-%d %H:%M:%S')" >> nginx_monitor.log;     ps -eo pid,comm,%cpu,%mem --sort=-%cpu | grep nginx | awk '{printf "PID: %-6s | Processo: %-10s | CPU: %-5s%% | Memória: %-5s%%\n", $1, $2, $3, $4}' >> nginx_monitor.log;     echo "----------------------------------------" >> nginx_monitor.log;     sleep 1; done