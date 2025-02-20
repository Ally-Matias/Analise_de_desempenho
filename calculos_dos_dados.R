# =============================================================
# Script para Teste de Hipótese e Geração de Gráficos de IC via Bootstrapping
# Objetivo: Verificar se o uso médio de CPU ultrapassa 80% 
#           utilizando dois métodos para calcular o intervalo de confiança.
# =============================================================

# 1. Carregar os pacotes necessários
library(ggplot2)
library(boot)

# 2. Definir parâmetros do teste
alpha <- 0.05   # Nível de significância para IC de 95%
mu0   <- 80     # Meta de uso de CPU (%)

# 3. Definir os arquivos e rótulos para cada grupo

# Grupo Apache
files_apache <- c("apache_cpu_10.log", "apache_cpu_50.log", "apache_cpu_100.log", "apache_cpu_200.log")
labels_apache <- c("Apache - 10 Usuários", "Apache - 50 Usuários", "Apache - 100 Usuários", "Apache - 200 Usuários")

# Grupo Nginx
files_nginx <- c("nginx_cpu_10.log", "nginx_cpu_50.log", "nginx_cpu_100.log", "nginx_cpu_200.log")
labels_nginx <- c("Nginx - 10 Usuários", "Nginx - 50 Usuários", "Nginx - 100 Usuários", "Nginx - 200 Usuários")

# 4. Função para calcular estatísticas completas (incluindo IC via t e bootstrapping)
calcula_estatisticas_completa <- function(file, label, R = 1000, alpha = 0.05) {
  dados <- read.table(file, header = FALSE)[, 1]
  n <- length(dados)
  media <- mean(dados)
  sd_val <- sd(dados)
  
  # Intervalo de Confiança via t
  t_crit <- qt(1 - alpha/2, df = n - 1)
  ci_t_lower <- media - t_crit * sd_val / sqrt(n)
  ci_t_upper <- media + t_crit * sd_val / sqrt(n)
  
  # Intervalo de Confiança via Bootstrapping
  set.seed(123)
  boot_res <- boot(data = dados, statistic = function(d, i) mean(d[i]), R = R)
  boot_ci_result <- boot.ci(boot_res, type = "perc")
  if (!is.null(boot_ci_result$percent)) {
    ci_boot_lower <- boot_ci_result$percent[4]
    ci_boot_upper <- boot_ci_result$percent[5]
  } else {
    ci_boot_lower <- NA
    ci_boot_upper <- NA
  }
  
  return(data.frame(File = label, Mean = media, SD = sd_val, N = n,
                    CI_t_lower = ci_t_lower, CI_t_upper = ci_t_upper,
                    CI_boot_lower = ci_boot_lower, CI_boot_upper = ci_boot_upper))
}

# 5. Processar os arquivos e consolidar os resultados em um data frame
df_apache <- do.call(rbind, mapply(calcula_estatisticas_completa, files_apache, labels_apache, SIMPLIFY = FALSE))
df_apache$Server <- "Apache"

df_nginx <- do.call(rbind, mapply(calcula_estatisticas_completa, files_nginx, labels_nginx, SIMPLIFY = FALSE))
df_nginx$Server <- "Nginx"

df_total <- rbind(df_apache, df_nginx)

# 6. Exibir o resumo consolidado (utilizando os IC via t e via Bootstrapping)
resumo <- paste0(
  "========== Resumo Consolidado ==========\n",
  paste(
    apply(df_total, 1, function(linha) {
      sprintf("%s | %s | Média: %.2f | Desvio: %.2f | n: %d | IC 95%% (t): [%.2f, %.2f] | IC 95%% (Boot): [%.2f, %.2f]",
              linha["Server"], linha["File"], as.numeric(linha["Mean"]), as.numeric(linha["SD"]),
              as.numeric(linha["N"]), as.numeric(linha["CI_t_lower"]), as.numeric(linha["CI_t_upper"]),
              as.numeric(linha["CI_boot_lower"]), as.numeric(linha["CI_boot_upper"]))
    }),
    collapse = "\n"
  ),
  "\n========================================\n"
)
cat(resumo)

# 7. Função para gerar histogramas (usando a função hist) com eixo x de 1 a 100
gera_histograma <- function(file, label) {
  file <- as.character(file)  # Garantir que 'file' seja uma string
  dados <- read.table(file, header = FALSE)[, 1]
  nome_arq <- paste0(gsub(" ", "_", label), "_hist.png")
  png(nome_arq, width = 800, height = 600)
  hist(dados, main = paste("Histograma -", label), xlab = "Uso de CPU (%)",
       col = "lightblue", border = "black", xlim = c(1, 100))
  dev.off()
}

# 8. Gerar histogramas para todos os arquivos
mapply(gera_histograma, c(files_apache, files_nginx), c(labels_apache, labels_nginx))

# 9. Função para gerar gráfico de intervalo de confiança via Bootstrapping com eixo y de 1 a 100
gera_grafico_ic_boot <- function(df_subset, titulo, arquivo) {
  png(arquivo, width = 800, height = 600)
  p <- ggplot(df_subset, aes(x = File, y = Mean, color = Server)) +
    geom_point(size = 4) +
    geom_errorbar(aes(ymin = CI_boot_lower, ymax = CI_boot_upper), width = 0.2) +
    geom_hline(yintercept = 80, linetype = "dashed", color = "red", linewidth = 1) +
    scale_y_continuous(limits = c(1, 100)) + 
    labs(title = titulo, x = "Arquivo / Grupo", y = "Média de Uso de CPU (%)") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  print(p)
  dev.off()
}

# 10. Gerar os gráficos de intervalo de confiança via Bootstrapping conforme solicitado

# a) Para cada servidor, para os grupos de 10, 50 e 100 usuários (gráfico separado para Apache e para Nginx)

# Apache: filtrar linhas que contenham '10', '50' ou '100 Usuários'
df_apache_10_50_100 <- subset(df_apache, grepl("10 Usuários|50 Usuários|100 Usuários", File))
gera_grafico_ic_boot(df_apache_10_50_100,
                     "IC via Bootstrapping - Apache (10, 50, 100 Usuários)",
                     "apache_ic_10_50_100.png")

# Nginx: filtrar linhas que contenham '10', '50' ou '100 Usuários'
df_nginx_10_50_100 <- subset(df_nginx, grepl("10 Usuários|50 Usuários|100 Usuários", File))
gera_grafico_ic_boot(df_nginx_10_50_100,
                     "IC via Bootstrapping - Nginx (10, 50, 100 Usuários)",
                     "nginx_ic_10_50_100.png")

# b) Para o grupo de 200 usuários: comparar Apache e Nginx juntos
df_200 <- subset(df_total, grepl("200 Usuários", File))
gera_grafico_ic_boot(df_200,
                     "IC via Bootstrapping - 200 Usuários (Comparativo)",
                     "ic_200_comparativo.png")

# 11. Gráfico do Teste de Hipótese usando os resultados do Bootstrapping
# Esse gráfico exibe, para todos os arquivos, a média e o IC via Boot com uma linha de referência em 80%
png("teste_hipotese_boot.png", width = 800, height = 600)
p_teste <- ggplot(df_total, aes(x = File, y = Mean, color = Server)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = CI_boot_lower, ymax = CI_boot_upper), width = 0.2) +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red", linewidth = 1) +
  scale_y_continuous(limits = c(1, 100)) +
  labs(title = "Teste de Hipótese: Uso de CPU (Bootstrapping)",
       subtitle = "Linha vermelha = referência de 80% de uso de CPU",
       x = "Arquivo / Grupo", y = "Média de Uso de CPU (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p_teste)
dev.off()

cat("Gráficos gerados com sucesso!\\n")

