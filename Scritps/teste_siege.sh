#!/usr/bin/env bash

# Níveis de usuários concorrentes para teste
NIVEIS_CONCORRENCIA=$1

NRP=$2
# Arquivo de log para salvar os resultados
ARQUIVO_LOG="resultado_siege.log"

# URL alvo (substitua pelo endereço do seu servidor)
URL=$3

# Limpa o log anterior, se existir
> "$ARQUIVO_LOG"

# Loop pelos níveis de concorrência
for NIVEL in "${NIVEIS_CONCORRENCIA[@]}"; do
  echo "==========================================" >> "$ARQUIVO_LOG"
  echo "Testando com $NIVEL usuários concorrentes" >> "$ARQUIVO_LOG"
  echo "==========================================" >> "$ARQUIVO_LOG"

  # Executa 5 vezes para cada nível
  for i in $(seq 1 5); do
    echo "--- Execução #$i ---" >> "$ARQUIVO_LOG"

    # Executa o Siege (ajuste o -r conforme necessário)
    # Aqui não usamos -q para que a saída completa (em JSON) seja gerada
    output=$(siege -v -b -c "$NIVEL" -r "$NRP" "$URL")

    # Utiliza o 'jq' para extrair as métricas (certifique-se de tê-lo instalado)
    transactions=$(echo "$output" | jq '.transactions')
    availability=$(echo "$output" | jq '.availability')
    elapsed_time=$(echo "$output" | jq '.elapsed_time')
    data_transferred=$(echo "$output" | jq '.data_transferred')
    response_time=$(echo "$output" | jq '.response_time')
    transaction_rate=$(echo "$output" | jq '.transaction_rate')
    throughput=$(echo "$output" | jq '.throughput')
    concurrency=$(echo "$output" | jq '.concurrency')
    successful=$(echo "$output" | jq '.successful_transactions')
    failed=$(echo "$output" | jq '.failed_transactions')
    longest=$(echo "$output" | jq '.longest_transaction')
    shortest=$(echo "$output" | jq '.shortest_transaction')

    # Escreve os resultados traduzidos no arquivo de log
    echo "Número total de transações:          $transactions" >> "$ARQUIVO_LOG"
    echo "Disponibilidade:                     $availability%" >> "$ARQUIVO_LOG"
    echo "Tempo total decorrido:               $elapsed_time seg" >> "$ARQUIVO_LOG"
    echo "Dados transferidos:                  $data_transferred MB" >> "$ARQUIVO_LOG"
    echo "Tempo médio de resposta:             $response_time seg" >> "$ARQUIVO_LOG"
    echo "Taxa de transações (trans/sec):      $transaction_rate" >> "$ARQUIVO_LOG"
    echo "Throughput (MB/s):                   $throughput" >> "$ARQUIVO_LOG"
    echo "Concorrência média:                  $concurrency" >> "$ARQUIVO_LOG"
    echo "Transações bem-sucedidas:            $successful" >> "$ARQUIVO_LOG"
    echo "Transações com falha:                $failed" >> "$ARQUIVO_LOG"
    echo "Transação mais longa:                $longest seg" >> "$ARQUIVO_LOG"
    echo "Transação mais curta:                $shortest seg" >> "$ARQUIVO_LOG"
    echo "" >> "$ARQUIVO_LOG"
  done
done

echo "Teste finalizado. Resultados salvos em '$ARQUIVO_LOG'."

