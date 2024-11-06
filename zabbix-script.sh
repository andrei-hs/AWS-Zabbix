#!/bin/bash
#
#	Script de Backup Arquivos Nuvem AWS
#
#Andrei Henrique Santos

# Verificação se todos os argumentos foram passados na execução do script
if [ $# -ne 4 ]; then
    echo "Para rodar este script é necessário enviar os seguintes argumentos: "
    echo "./zabbix-script.sh <token-zabbix> <ip-zabbix> <nome-buckets3> <template-id>"
    exit 1
fi

# Adiciona os argumentos em suas respectivas variáveis
AUTH_TOKEN=$1
IP_ZABBIX=$2
BUCKET_S3=$3
TEMPLATE_ID=$4

current_time=$(date +%s)
month_ago=$(date -d "1 month ago" +%s)

# Função responsável por fazer a requisição a API do Zabbix
zabbix_request() {
    local id="$1"
    local url_hostname="$2"
    local token="$3"
    local method="$4"
    local params="$5"

    response=$(curl --silent --request POST \
        --url "http://${url_hostname}/zabbix/api_jsonrpc.php" \
        --header "Authorization: Bearer ${token}" \
        --header "Content-Type: application/json-rpc" \
        --data "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"${method}\",
            \"params\": ${params},
            \"id\": ${id}
        }")

    echo $response
}

# Realiza um requisição para receber os hosts associados a um template específico e os salva em uma variável 
hosts=$(zabbix_request 1 $IP_ZABBIX $AUTH_TOKEN "template.get" "{\"output\": \"hosts\",\"templateids\": \"$TEMPLATE_ID\",\"selectHosts\": [\"hostid\", \"host\"]}" | jq -c '.result[] | .hosts[]')

# Inicia um loop para ir de host em host e requerer seus itens
echo "${hosts}" | while read -r host; do
    hostid=$(echo "$host" | jq -r '.hostid')
    hostname=$(echo "$host" | jq -r '.host')

    echo "Host Name: $hostname"

    # Requere os itens de um host e os salva nesta variável
    itens=$(zabbix_request 2 $IP_ZABBIX $AUTH_TOKEN "item.get" "{\"output\": [\"itemid\", \"name\", \"value_type\"], \"hostids\": \"$hostid\"}" | jq -c '.result[]') 

    # Faz um outro loop para ir de item e item na lista e requerer seu histórico até de um mês atrás
    echo "${itens}" | while read -r item; do

        itemid=$(echo "$item" | jq -r '.itemid')
        itemname=$(echo "$item" | jq -r '.name')
        itemvaluetype=$(echo "$item" | jq -r '.value_type')

        echo "	Item Name: $itemname"

        # Faz uma requisição para capturar o histórico de um item
        history=$(zabbix_request 3 $IP_ZABBIX $AUTH_TOKEN "history.get" "{\"output\": [\"clock\", \"value\"], \"history\": \"$itemvaluetype\", \"itemids\": \"$itemid\", \"sortfield\": \"clock\", \"sortorder\": \"ASC\", \"time_from\": \"$month_ago\", \"time_till\": \"$current_time\"}" | jq -c '.result')

        # Gera os diretórios que serão enviados a nuvem no diretório local "/tmp/upload-cloud"
        mount_directory="/tmp/upload_cloud/logs/$(date +%Y)/$(date +%B)/${hostname}/${itemname}"
        mkdir -p "${mount_directory}" 

        # Adiciona o JSON do histório de um item em um arquivo "values.json" no seu devido diretório 
        echo $history > "${mount_directory}/values.json"

        # Formata os valores do JSON do histórico de um item em um arquivo de planilha .csv no seu respectivo diretório
        echo $history | jq -r '.[] | [(.clock | tonumber | strftime("%d/%m/%Y")), (.clock | tonumber | strftime("%H:%M:%S")), .value] | @csv' | sed 's/"//g' > "${mount_directory}/spreadsheet.csv" 
    done
done

# Envia todos os arquivos dentro da pasta "/tmp/upload-cloud" junto com seus respectivos diretórios em um Bucket S3 da AWS
aws s3 cp "/tmp/upload_cloud/" "s3://${BUCKET_S3}/" --recursive
