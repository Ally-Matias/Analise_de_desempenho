#!/bin/bash

while true; do      echo "$(date '+%Y-%m-%d %H:%M:%S')" >> apache_monitor.log;     ps -eo pid,comm,%cpu,%mem --sort=-%cpu | grep apache2 | awk '{printf "PID: %-6s | Processo: %-10s | CPU: %-5s%% | Memória: %-5s%%\n", $1, $2, $3, $4}' >> apache_monitor.log;     echo "----------------------------------------" >> apache_monitor.log;     sleep 1; done