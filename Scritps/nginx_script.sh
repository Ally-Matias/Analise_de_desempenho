#!/bin/bash

LOGFILE="nginx_monitor.log"
INTERVAL=1

while true; do
    # Registra a data e hora
    echo "Data: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
    
    # Registra a utilização de CPU dos processos do Nginx
    echo "Processos Nginx (apenas CPU):" >> "$LOGFILE"
    ps -eo pid,comm,%cpu --sort=-%cpu | grep nginx | \
        awk '{printf "PID: %-6s | Processo: %-10s | CPU: %-5s%%\n", $1, $2, $3}' >> "$LOGFILE"
    
    # Registra a utilização de memória da máquina
    echo "Uso de memória da máquina:" >> "$LOGFILE"
    free -m | awk 'NR==2 {printf "Usado: %-6s MB | Total: %-6s MB | Livre: %-6s MB\n", $3, $2, $4}' >> "$LOGFILE"
    
    echo "----------------------------------------" >> "$LOGFILE"
    
    sleep $INTERVAL
done