#!/bin/bash
LOGFILE="nginx_cpu.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')]" >> "$LOGFILE"

while true; do
    # Grava o timestamp

    # Executa o top e extrai a coluna de %CPU para linhas contendo "nginx",
    # converte a vírgula em ponto e grava apenas os valores maiores que 0.
    top -b -n 1 | grep -oP '^(?=.*nginx)(?:\s*\S+\s+){8}\K\S+' | \
    awk '{
        gsub(/,/, ".");
        if ($1 > 0) print $1
    }' >> "$LOGFILE"

    echo "---" >> "$LOGFILE"
    sleep 2
done

