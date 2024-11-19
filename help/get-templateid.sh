#!/bin/bash
#
#       Script de Backup Arquivos Nuvem AWS - Requere o ID do template pelo seu nome
#
#Andrei Henrique Santos

# Verificação se todos os argumentos foram passados na execução do script
if [ $# -ne 3 ]; then
    echo "Para rodar este script é necessário enviar os seguintes argumentos: "
    echo "./get-templateid.sh <template-name> <token-zabbix> <ip-zabbix>"
    exit 1
fi

TEMPLATE_NAME=$1
AUTH_TOKEN=$2
IP_ZABBIX=$3

# Realiza uma requisição para receber o Nome e o ID de um template
template_info=$(./../utils/zabbix-request.sh 1 $IP_ZABBIX $AUTH_TOKEN "template.get" "{\"output\": [\"name\", \"templateid\"], \"filter\": {\"name\": \"$TEMPLATE_NAME\"}}" | jq -c '.result[]')

templateinfo_name=$(echo $template_info | jq -r '.name')
templateinfo_id=$(echo $template_info | jq -r '.templateid')

# Verifica se o nome do template passado no argumento de execução do script é igual ao nome do template recebido
if [[ "$TEMPLATE_NAME" != "$templateinfo_name" ]]; then
    echo "Houve um erro ao procurar o template"
    echo "Verifique se o nome do template está correto"
    exit 1 
fi 

echo "Nome: $templateinfo_name" 
echo "ID: $templateinfo_id"
