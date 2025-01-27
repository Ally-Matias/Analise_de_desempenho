# Mininet
Repositório dedicado ao armazenamento de scripts para análise de desempenho de redes utilizando o emulador de redes Mininet.

## O que é o Mininet?

O Mininet emula uma rede completa de hosts, links e switches em uma única máquina. Para criar uma rede de exemplo com dois hosts e um switch, basta executar:

```bash
sudo mn
```

O Mininet é muito útil para desenvolvimento interativo, testes e demonstrações, especialmente aqueles que utilizam OpenFlow e SDN. Controladores de rede baseados em OpenFlow, prototipados no Mininet, podem geralmente ser transferidos para hardware com mudanças mínimas, permitindo execução em alta performance.

Como funciona?
O Mininet cria redes virtuais utilizando virtualização baseada em processos e namespaces de rede — recursos disponíveis em kernels Linux mais recentes.

No Mininet, os hosts são emulados como processos bash executados em um namespace de rede. Assim, qualquer código que normalmente seria executado em um servidor Linux (como um servidor web ou um programa cliente) funcionará perfeitamente dentro de um "Host" do Mininet.
Cada "Host" possui sua própria interface de rede privada e só pode acessar seus próprios processos.
Os switches no Mininet são baseados em software, como o Open vSwitch ou o switch de referência do OpenFlow.
Os links são implementados como pares de ethernet virtuais (veth pairs), que residem no kernel Linux e conectam os switches emulados aos hosts emulados (processos).
Com isso, o Mininet fornece uma forma eficiente de emular redes completas em uma única máquina, sendo uma ferramenta poderosa para o desenvolvimento e prototipagem de soluções baseadas em SDN.

<br>

## Documentação

Além da documentação da API (que pode ser gerada com o comando `make doc`), há muitas informações úteis disponíveis, incluindo um tutorial sobre o Mininet e uma introdução à API Python, no [Site Oficial do Mininet](http://mininet.org).  

Também existe uma **wiki**, especialmente na seção de Perguntas Frequentes (FAQ), disponível em [http://faq.mininet.org](http://faq.mininet.org).  

<br>

## Descrição dos scripts que criamos

Script | Descrição
------ | -----------
single.py | Descrição
linear.py | Descrição
ring.py | Descrição
run_cmds.py | Descrição



### Padrões que usamos:

| tipo de commit   | palavra-chave |
| ---------------- | :-----------: |
| commit inicial   |     init      |
| novo recurso     |     feat      |
| correção de bugs |      fix      |
| refatoração      |     refac     |

<h2>🔷 Autores:</h2>
<div>
  <table>
    <tr>
      <td align="center">
        <a href="https://github.com/Ally-Matias">
          <img src="https://avatars.githubusercontent.com/u/98532868?v=4" alt="Alliquison Matias da Silva"
            width="100px">
          <br>
          <sub><b>Alliquison Matias</b></sub>
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/Chiet4" >
          <img src="https://avatars.githubusercontent.com/u/111232477?v=4" alt="Anchieta Albano"
            width="100px" >
          <br>
          <sub><b>Anchieta Albano</b></sub>
        </a>
      </td>
    </tr>
  </table>
</div>
