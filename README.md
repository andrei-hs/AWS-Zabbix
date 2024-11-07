# Backup de Itens do Zabbix

Este script em Shell tem como objetivo realizar o backup dos valores dos itens de hosts configurados no Zabbix que pertencem a um template, como "Servidores". Ele utiliza o `curl` para fazer requisições à API do Zabbix, captura essas informações, formata os dados em arquivos e os envia para um bucket S3 na AWS.

## Requisitos

Para utilizar este script, você precisará de:

- **Distribuição Linux**: O script deve ser executado em um sistema operacional Linux.
- **Hosts vinculados a um template**: Os hosts que você deseja fazer backup devem estar vinculados a um template específico.
- **ID do template**: Você precisará do ID do template desejado.
- **Bucket S3**: O script deve ter acesso a um bucket S3 na AWS.
- **TOKEN de acesso à API do Zabbix**: É necessário um token válido para autenticação na API do Zabbix.
- **Endereço IP do servidor Zabbix**: Informe o IP do servidor Zabbix a ser consultado durante a execução do script.

### Dependências

Esta é a lista dos pacotes que o script utiliza:

- curl
- jq
- aws-cli

## Arquivo de configuração

Ao executar o script pela primeira vez, conforme descrito na seção **Como Usar**, um arquivo de configuração chamado `config.sh` será criado automaticamente no mesmo diretório onde o script está localizado.

Este arquivo facilita a execução do script, pois nele serão salvos os últimos parâmetros utilizados. Assim, ao rodar o script novamente, não será necessário fornecer os mesmos parâmetros. O script irá automaticamente utilizar os valores salvos no arquivo `config.sh`. Caso deseje utilizar novos parâmetros, basta editar o arquivo ou passar os novos valores diretamente ao executar o script, o que atualizará automaticamente o arquivo de configuração.

### Exemplo do arquivo `config.sh`

Caso deseje criar o arquivo de configuração manualmente, sem precisar executá-lo pela primeira vez, segue um exemplo do conteúdo esperado:

```bash
# Arquivo de configuração
AUTH_TOKEN="seu-token-aqui"
IP_ZABBIX="ip-do-zabbix"
BUCKET_S3="nome-do-bucket-s3-aws"
TEMPLATE_ID="id-do-template"
```

## Como Usar

1. Clone este repositório em sua máquina local.
2. Baixe e configure as dependências.
3. Execute o script em um terminal.

    ```bash
    ./upload-zabbix.sh <token-zabbix> <ip-zabbix> <nome-buckets3> <template-id>
    ```
### Estrutura de Diretórios Gerada

Após a execução do script, a estrutura de diretórios e arquivos será semelhante a esta:

```bash
zabbix@SCRIPT:~$ tree /tmp/upload_cloud/
/tmp/upload_cloud/
└── logs
    └── 2024
        └── Novembro
            ├── Servidor DHCP
            │   ├── Porcentagem uso da CPU
            │   │   ├── spreadsheet.csv
            │   │   └── values.json
            │   ├── Porcentagem uso de memória
            │   │   ├── spreadsheet.csv
            │   │   └── values.json
            │   ├── SSH Disponibilidade
            │   │   ├── spreadsheet.csv
            │   │   └── values.json
            │   └── Teste de conectividade
            │       ├── spreadsheet.csv
            │       └── values.json
            └── Servidor IoT
                ├── Porcentagem uso da CPU
                │   ├── spreadsheet.csv
                │   └── values.json
                ├── Porcentagem uso de memória
                │   ├── spreadsheet.csv
                │   └── values.json
                ├── SSH Disponibilidade
                │   ├── spreadsheet.csv
                │   └── values.json
                └── Teste de conectividade
                    ├── spreadsheet.csv
                    └── values.json
```
