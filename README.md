# Backup de Itens do Zabbix

Este script em Shell tem como objetivo realizar o backup dos valores dos itens de hosts configurados no Zabbix que pertencem a um template, como "Servidores". Ele utiliza o `curl` para fazer requisições à API do Zabbix, captura essas informações, as formata em arquivos e as envia para um bucket S3 na AWS.

## Requisitos

Para utilizar este script, você precisará:

- **Distribuição Linux**: O script deve ser executado em um sistema operacional Linux.
- **Hosts vinculados a um template**: Os hosts que você deseja fazer backup devem estar vinculados a um template específico.
- **ID do template**: Você precisará do ID do template desejado.
- **Bucket S3 com acesso público**: O script deve ter acesso a um bucket S3 na AWS que esteja configurado para acesso público.
- **TOKEN de acesso à API do Zabbix**: É necessário um token válido para autenticação na API do Zabbix.
- **Endereço IP do servidor Zabbix**: Informe o IP do servidor Zabbix que será consultado na execução do script.

## Como Usar

1. Clone este repositório em sua máquina local.
2. Execute o script em um terminal.

### Exemplo de Execução

```bash
./zabbix-script.sh <token-zabbix> <ip-zabbix> <nome-buckets3> <template-id>
