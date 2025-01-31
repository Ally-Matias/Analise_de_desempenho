#!/usr/bin/python

from mininet.net import Mininet
from mininet.node import Controller, OVSKernelSwitch
from mininet.link import TCLink
from mininet.cli import CLI

def custom_topology():
    # Criação da rede
    net = Mininet(controller=Controller, switch=OVSKernelSwitch, link=TCLink)

    # Adicionar controladores (opcional)
    net.addController('c0')

    # Adicionar switches e hosts
    switch = net.addSwitch('s1')
    client1 = net.addHost('h1', ip='10.0.0.1')
    client2 = net.addHost('h2', ip='10.0.0.2')
    server1 = net.addHost('h3', ip='10.0.0.3')  # Servidor Nginx
    server2 = net.addHost('h4', ip='10.0.0.4')  # Servidor Apache

    # Configurar links
    net.addLink(client1, switch)
    net.addLink(client2, switch)
    net.addLink(server1, switch)
    net.addLink(server2, switch)

    # Iniciar a rede
    net.start()

    # Configurar os servidores
    server1.cmd('apt update && apt install -y nginx')
    server2.cmd('apt update && apt install -y apache2')

    print("Servidores configurados. Acesse os serviços em:")
    print(" - Nginx (h3): http://10.0.0.3")
    print(" - Apache (h4): http://10.0.0.4")


    # Inicia os servidores
    print("Iniciando Nginx no Server1...")
    net.get('h3').cmd('service nginx start')

    print("Iniciando Apache no Server2...")
    net.get('h4').cmd('service apache2 start')

    # Testa a conectividade
    print("Testando conectividade entre os hosts...")
    net.pingAll()

    # Executa Siege nos clientes
    print("Rodando Siege no Client1 contra o Server1 (Nginx)...")
    net.get('h1').cmd('siege -c 10 -t10s http://10.0.0.2 &')

    print("Rodando Siege no Client2 contra o Server2 (Apache)...")
    net.get('h2').cmd('siege -c 10 -t10s http://10.0.0.3 &')

    # Entrar no CLI do Mininet
    CLI(net)

    # Encerrar a rede
    net.stop()

if __name__ == '__main__':
    custom_topology()
