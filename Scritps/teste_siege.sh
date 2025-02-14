#!/usr/bin/env bash


# Níveis de usuários concorrentes para teste
NIVEIS_CONCORRENCIA=$1

NRP=$2
# Arquivo de log para salvar os resultados
ARQUIVO_LOG_DADOS="dados_transferidosMB.log"
ARQUIVO_LOG_DISPONIBILIDADE="disponibilidade_percent.log"
ARQUIVO_LOG_TEMPO_MEDIO="tempo_medio_seg.log"
ARQUIVO_LOG_FALHA="siege_falhas.log"
# URL alvo (substitua pelo endereço do seu servidor)
URL=$3

# Loop pelos níveis de concorrência
for NIVEL in "${NIVEIS_CONCORRENCIA[@]}"; do


  # Executa 5 vezes para cada nível
  for i in $(seq 1 5); do

    # Executa o Siege (ajuste o -r conforme necessário)
    # Aqui não usamos -q para que a saída completa (em JSON) seja gerada
    output=$(siege -v -b -c "$NIVEL" -r "$NRP" "$URL")

    # Utiliza o 'jq' para extrair as métricas (certifique-se de tê-lo instalado)

    availability=$(echo "$output" | jq '.availability')
    data_transferred=$(echo "$output" | jq '.data_transferred')
    response_time=$(echo "$output" | jq '.response_time')
    failed=$(echo "$output" | jq '.failed_transactions')

    # Escreve os resultados traduzidos no arquivo de log
    echo $availability >> "$ARQUIVO_LOG_DISPONIBILIDADE"
    echo $data_transferred >> "$ARQUIVO_LOG_DADOS"
    echo $response_time >> "$ARQUIVO_LOG_TEMPO_MEDIO"
    echo $failed >> "$ARQUIVO_LOG_FALHA"

   done
done

