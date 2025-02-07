#!/usr/bin/env python3

from mininet.net import Mininet
from mininet.node import OVSKernelSwitch, RemoteController
from mininet.link import TCLink
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.util import pmonitor
import time
import sys

class WebServerTopo(Topo):
    def build(self):
        # Configuração QoS
        switch = self.addSwitch('s1', protocols='OpenFlow13')
        
        # Clientes
        clients = [('h1', '10.0.0.1'), ('h2', '10.0.0.2')]
        
        # Servidores
        servers = [('h3', '10.0.0.3'), ('h4', '10.0.0.4')]
        
        # Adiciona todos os hosts
        for name, ip in clients + servers:
            self.addHost(name, ip=ip)
        
        # Cenário Crítico 
        for name, _ in clients + servers:
            self.addLink(
                name, switch,
                bw=20,          # Largura de banda restrita
                delay='150ms',  # Latência alta
                loss=5,         # 5% de perda de pacotes
                use_htb=True,
                cls=TCLink,
                r2q=2000
            )

def setup_environment(net):
    """Configuração dos servidores web"""
    info("\n*** Configurando servidores:\n")
    
    # Nginx
    h3 = net.get('h3')
    h3.cmd('apt-get update && apt-get install -y nginx >/dev/null 2>&1')
    h3.cmd('dd if=/dev/urandom of=/var/www/html/test.bin bs=1M count=50 status=none')
    h3.cmd('systemctl start nginx')
    
    # Apache com configuração otimizada
    h4 = net.get('h4')
    h4.cmd('apt-get update && apt-get install -y apache2 >/dev/null 2>&1')
    h4.cmd('a2enmod mpm_event && systemctl restart apache2')
    h4.cmd('dd if=/dev/urandom of=/var/www/html/test.bin bs=1M count=50 status=none')

def install_tools(net):
    """Instalação otimizada de dependências"""
    info("\n*** Instalando ferramentas:\n")
    for host in net.hosts:
        host.cmd('apt-get update && apt-get install -y siege sysstat iftop iputils-ping >/dev/null 2>&1')

def monitor_resources(net):
    """Monitoramento avançado de recursos"""
    info("\n*** Iniciando coleta de métricas:\n")
    monitors = {}
    
    # Inicia pings contínuos para medir perda de pacotes ------------------ (NAO ESTA FUNCIONANDO AINDA)
    info("\n*** Iniciando teste de ping:\n")
    net.get('h1').popen('ping -i 1 -W 1 10.0.0.3 > /tmp/h1_ping.log &')
    net.get('h2').popen('ping -i 1 -W 1 10.0.0.4 > /tmp/h2_ping.log &')
    
    for server in ['h3', 'h4']:
        host = net.get(server)
        host.cmd('rm -f /tmp/metrics.log')
        cmd = '''
        while true; do
            echo "$(date +%s) $(mpstat 1 1 | awk '/Average:/ {printf "%.1f", 100 - $12}') \
            $(free -m | awk '/Mem:/ {print $3}') \
            $(iftop -i eth0 -t -s 1 2>/dev/null | grep 'Total send rate' | awk '{print $4}')" >> /tmp/metrics.log
        done &
        '''
        monitors[server] = host.popen(cmd, shell=True)
    
    return monitors

def run_stress_test(net, server_ip, duration=300):
    """Execução de teste de carga"""
    client = net.get('h1' if server_ip == '10.0.0.3' else 'h2')
    
    return client.popen(
        f'siege -c 100 -t{duration}S --log=/tmp/siege.log http://{server_ip}/test.bin',
        shell=True
    )

def analyze_results(net):
    """Geração de relatório"""
    info("\n*** Resultados finais:\n")
    
    # Novo: Análise de perda de pacotes
    info("\n\033[1;35m=== PERDA DE PACOTES ===\033[0m\n")
    nginx_loss = net.get('h1').cmd('grep "packet loss" /tmp/h1_ping.log | tail -n 1 | awk -F\'%\' \'{print $1}\' | awk \'{print $NF}\'')
    apache_loss = net.get('h2').cmd('grep "packet loss" /tmp/h2_ping.log | tail -n 1 | awk -F\'%\' \'{print $1}\' | awk \'{print $NF}\'')
    
    info(f"Nginx: {nginx_loss.strip()}% de perda\n")
    info(f"Apache: {apache_loss.strip()}% de perda\n")
    
    # Métricas originais
    for server in ['h3', 'h4']:
        host = net.get(server)
        info(f"\n\033[1;35m=== {server.upper()} ===\033[0m\n")
        
        # CPU
        cpu_avg = host.cmd("awk '{total += $2; count++} END {printf \"%.1f%%\", total/count}' /tmp/metrics.log")
        info(f"CPU Médio: {cpu_avg.strip()}\n")
        
        # Memória
        mem_max = host.cmd("awk 'BEGIN {max=0} {if($3>max) max=$3} END {print max\"MB\"}' /tmp/metrics.log")
        info(f"Memória Máxima: {mem_max.strip()}\n")
        
        # Rede
        bw_peak = host.cmd("awk 'BEGIN {max=0} {split($4,a,\"MB\"); if(a[1]>max) max=a[1]} END {print max\"MB\"}' /tmp/metrics.log")
        info(f"Pico de Banda: {bw_peak.strip()}\n")

def main():
    setLogLevel('info')
    
    # Cria rede com controlador remoto
    net = Mininet(
        topo=WebServerTopo(),
        switch=OVSKernelSwitch,
        controller=lambda name: RemoteController(name, ip='127.0.0.1', port=6653),
        link=TCLink,
        autoSetMacs=True
    )
    
    try:
        net.start()
        
        # Fluxo de execução otimizado
        install_tools(net)
        setup_environment(net)
        monitors = monitor_resources(net)
        
        info("\n\033[1;32m=== TESTE INICIADO ===\033[0m\n")
        nginx_test = run_stress_test(net, '10.0.0.3')
        apache_test = run_stress_test(net, '10.0.0.4')
        
        # Barra de progresso
        for i in range(300):
            time.sleep(1)
            info(f'\rProgresso: [{"#"*(i//30)}{" "*(10-(i//30))}] {i/3}%')
            sys.stdout.flush()
        
        analyze_results(net)
        
    finally:
        net.stop()

if __name__ == '__main__':
    main()



# sudo apt-get purge openvswitch-testcontroller
# sudo apt-get install openvswitch-testcontroller
# sudo cp /usr/bin/ovs-testcontroller /usr/bin/controller

# Garanta que o controlador está rodando
# sudo killall ovs-testcontroller 2>/dev/null
# sudo ovs-testcontroller ptcp:6653 &

# # Execute o script
# sudo ./script.py