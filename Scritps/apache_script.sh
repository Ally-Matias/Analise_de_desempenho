#!/bin/bash

#!/bin/bash

while true; do
        echo "$(date '+%Y-%m-%d %H:%M:%S')" >> apache_monitor.log;
        ps -eo pid,comm,%cpu --sort=-%cpu | grep apache2 | awk '{printf "PID: %-6s | Processo: %-10s | CPU: %-5s%%\n", $1, $2, $3, $4}' >> apache_monitor.log;
        free -m | awk 'NR==2{printf "Memória Total: %sMB | Usada: %MB | Livre: %sMB | Cache: %sMB\n", $2, $3, $4, $6}' >> apache_monitor.log
        echo "----------------------------------------" >> apache_monitor.log;
        sleep 1; done
