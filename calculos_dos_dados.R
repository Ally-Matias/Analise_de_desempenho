# =============================================================
# Script para Teste de Hipótese: Uso de CPU
# Autor: Seu Nome
# Data: AAAA-MM-DD
# =============================================================

# 1. Carregar o pacote necessário
library(ggplot2)

# 2. Definir parâmetros do teste
alpha <- 0.05   # Nível de significância para IC de 95%
mu0   <- 80     # Meta de uso de CPU (%)

# 3. Definir os arquivos e rótulos para cada grupo

# Grupo Apache
files_apache <- c("apache_cpu_10.log", "apache_cpu_50.log","apache_cpu_100.log","apache_cpu_200.log")
labels_apache <- c("Apache - 10 Usuários","Apache - 50 Usuários","Apache - 100 Usuários", "Apache - 200 Usuários")

# Grupo Nginx
files_nginx <- c("nginx_cpu_10.log", "nginx_cpu_50.log", "nginx_cpu_100.log", "nginx_cpu_200.log")
labels_nginx <- c("Nginx - 10 Usuários", "Nginx - 50 Usuários", "Nginx - 100 Usuários", "Nginx - 200 Usuários")

# 4. Função para calcular as estatísticas de cada arquivo
calcula_estatisticas <- function(file, label) {
  dados <- read.table(file, header = FALSE)[, 1]
  n <- length(dados)
  media <- mean(dados)
  sd_val <- sd(dados)
  # Intervalo de Confiança (t)
  t_crit <- qt(1 - alpha/2, df = n - 1)
  ci_lower <- media - t_crit * sd_val / sqrt(n)
  ci_upper <- media + t_crit * sd_val / sqrt(n)
  # Teste unilateral: H0: μ <= 80 vs. H1: μ > 80
  t_stat <- (media - mu0) / (sd_val / sqrt(n))
  p_value <- 1 - pt(t_stat, df = n - 1)
  
  return(data.frame(Server = NA, File = label, Mean = media, SD = sd_val, N = n,
                    CI_lower = ci_lower, CI_upper = ci_upper, t_stat = t_stat, p_value = p_value))
}

# 5. Processar os arquivos e consolidar os resultados em um data frame
df_apache <- do.call(rbind, mapply(calcula_estatisticas, files_apache, labels_apache, SIMPLIFY = FALSE))
df_apache$Server <- "Apache"

df_nginx <- do.call(rbind, mapply(calcula_estatisticas, files_nginx, labels_nginx, SIMPLIFY = FALSE))
df_nginx$Server <- "Nginx"

df_total <- rbind(df_apache, df_nginx)

# 6. Exibir o resumo consolidado (em um único bloco)
resumo <- paste0(
  "========== Resumo Consolidado ==========\n",
  paste(
    apply(df_total, 1, function(linha) {
      sprintf("%s | %s | Média: %.2f | Desvio: %.2f | n: %d | IC 95%% (t): [%.2f, %.2f] | t: %.2f | p-valor: %.3f",
              linha["Server"], linha["File"], as.numeric(linha["Mean"]), as.numeric(linha["SD"]),
              as.numeric(linha["N"]), as.numeric(linha["CI_lower"]), as.numeric(linha["CI_upper"]),
              as.numeric(linha["t_stat"]), as.numeric(linha["p_value"]))
    }),
    collapse = "\n"
  ),
  "\n========================================\n"
)

cat(resumo)

# 7. Gerar um único gráfico para o teste de hipótese
#    O gráfico exibe a média de uso de CPU (com seus intervalos de confiança)
#    e uma linha horizontal de referência em 80%.
png("teste_hipotese.png", width = 800, height = 600)
ggplot(df_total, aes(x = File, y = Mean, color = Server)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = CI_lower, ymax = CI_upper), width = 0.2) +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red", size = 1) +
  labs(title = "Teste de Hipótese: Uso de CPU",
       subtitle = "Linha vermelha = referência de 80% de uso",
       x = "Arquivo / Grupo", y = "Média de Uso de CPU (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

# =============================================================
# Script: Comparação de Intervalos de Confiança (Z-Score vs Bootstrapping)
# Objetivo: Verificar se o uso médio de CPU ultrapassa 80% 
#           utilizando dois métodos para calcular o intervalo de confiança.
# Autor: Seu Nome
# Data: AAAA-MM-DD
# =============================================================

# 1. Carregar os pacotes necessários
library(boot)
library(ggplot2)

# 2. Função para calcular a média (para bootstrapping)
mean_fun <- function(data, indices) {
  return(mean(data[indices]))
}

# 3. Função para calcular estatísticas, incluindo IC via z-score e bootstrapping
calcula_estatisticas <- function(file, label, R = 1000, alpha = 0.05) {
  dados <- read.table(file, header = FALSE)[, 1]
  n <- length(dados)
  media <- mean(dados)
  sd_val <- sd(dados)
  
  # Intervalo de confiança via z-score
  z_crit <- qnorm(1 - alpha/2)
  ci_z_lower <- media - z_crit * sd_val / sqrt(n)
  ci_z_upper <- media + z_crit * sd_val / sqrt(n)
  
  # Intervalo de confiança via bootstrapping
  set.seed(123)
  boot_res <- boot(data = dados, statistic = mean_fun, R = R)
  boot_ci <- boot.ci(boot_res, type = "perc")
  if (!is.null(boot_ci$percent)) {
    ci_boot_lower <- boot_ci$percent[4]
    ci_boot_upper <- boot_ci$percent[5]
  } else {
    ci_boot_lower <- NA
    ci_boot_upper <- NA
  }
  
  return(data.frame(File = label, Mean = media, SD = sd_val, N = n,
                    CI_z_lower = ci_z_lower, CI_z_upper = ci_z_upper,
                    CI_boot_lower = ci_boot_lower, CI_boot_upper = ci_boot_upper))
}

# 4. Definir os arquivos e rótulos para cada grupo

## Grupo Apache
files_apache <- c("apache_cpu_10.log", "apache_cpu_50.log", "apache_cpu_100.log", "apache_cpu_200.log")
labels_apache <- c("Apache - 10 Usuários", "Apache - 50 Usuários", "Apache - 100 Usuários", "Apache - 200 Usuários")

## Grupo Nginx
files_nginx <- c("nginx_cpu_10.log", "nginx_cpu_50.log", "nginx_cpu_100.log", "nginx_cpu_200.log")
labels_nginx <- c("Nginx - 10 Usuários", "Nginx - 50 Usuários", "Nginx - 100 Usuários", "Nginx - 200 Usuários")

# 5. Processar os arquivos e consolidar os resultados
df_apache <- do.call(rbind, mapply(calcula_estatisticas, files_apache, labels_apache, SIMPLIFY = FALSE))
df_apache$Server <- "Apache"

df_nginx <- do.call(rbind, mapply(calcula_estatisticas, files_nginx, labels_nginx, SIMPLIFY = FALSE))
df_nginx$Server <- "Nginx"

df_total <- rbind(df_apache, df_nginx)

# 6. Exibir o resumo consolidado (com os intervalos de confiança via Z e Bootstrapping)
resumo <- paste0(
  "========== Resumo Consolidado ==========\n",
  paste(
    apply(df_total, 1, function(linha) {
      sprintf("%s | %s | Média: %.2f | Desvio: %.2f | n: %d | IC 95%% (Z): [%.2f, %.2f] | IC 95%% (Boot): [%.2f, %.2f]",
              linha["Server"], linha["File"], as.numeric(linha["Mean"]), as.numeric(linha["SD"]),
              as.numeric(linha["N"]), as.numeric(linha["CI_z_lower"]), as.numeric(linha["CI_z_upper"]),
              as.numeric(linha["CI_boot_lower"]), as.numeric(linha["CI_boot_upper"]))
    }),
    collapse = "\n"
  ),
  "\n========================================\n"
)

cat(resumo)

# 7. Preparar os dados para o gráfico comparativo
# Criar dois data frames: um para o intervalo via Z e outro para Bootstrapping
df_z <- data.frame(Server = df_total$Server, File = df_total$File, Mean = df_total$Mean,
                   CI_lower = df_total$CI_z_lower, CI_upper = df_total$CI_z_upper, Metodo = "Z-Score")
df_boot <- data.frame(Server = df_total$Server, File = df_total$File, Mean = df_total$Mean,
                      CI_lower = df_total$CI_boot_lower, CI_upper = df_total$CI_boot_upper, Metodo = "Bootstrapping")
df_plot <- rbind(df_z, df_boot)

# Converter 'File' para fator (para manter a ordem desejada)
df_plot$File <- factor(df_plot$File, levels = unique(df_total$File))

# 8. Gerar um único gráfico comparativo dos intervalos de confiança
png("intervalos_comparacao.png", width = 800, height = 600)
ggplot(df_plot, aes(x = File, y = Mean, color = Metodo)) +
  geom_point(position = position_dodge(width = 0.5), size = 4) +
  geom_errorbar(aes(ymin = CI_lower, ymax = CI_upper), position = position_dodge(width = 0.5), width = 0.2) +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red", size = 1) +
  facet_wrap(~ Server) +
  labs(title = "Comparação de Intervalos de Confiança: Z-Score vs Bootstrapping",
       subtitle = "Linha vermelha = referência de 80% de uso de CPU",
       x = "Arquivo / Grupo", y = "Média de Uso de CPU (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

