#!/bin/bash
#
#       Script de Backup Arquivos Nuvem AWS - Paralelismo Processos de Itens
#
#Andrei Henrique Santos

# Carrega o arquivo de configuração
source config.sh

item=$1
hostname=$2

current_time=$(date +%s)
month_ago=$(date -d "1 month ago" +%s)

itemid=$(echo "$item" | jq -r '.itemid')
itemname=$(echo "$item" | jq -r '.name')
itemvaluetype=$(echo "$item" | jq -r '.value_type')

# Faz uma requisição para capturar o histórico de um item
history=$(./utils/zabbix-request.sh 1 $IP_ZABBIX $AUTH_TOKEN "history.get" "{\"output\": [\"clock\", \"value\"], \"history\": \"$itemvaluetype\", \"itemids\": \"$itemid\", \"sortfield\": \"clock\", \"sortorder\": \"ASC\", \"time_from\": \"$month_ago\", \"time_till\": \"$current_time\"}" | jq -c '.result')

# Gera os diretórios que serão enviados a nuvem no diretório local "/tmp/upload-cloud"
mount_directory="/tmp/upload_cloud/logs/$(date +%Y)/$(date +%B)/${hostname}/${itemname}"
mkdir -p "${mount_directory}"

# Adiciona o JSON do histório de um item em um arquivo "values.json" no seu devido diretório
echo $history > "${mount_directory}/values.json"

# Formata os valores do JSON do histórico de um item em um arquivo de planilha .csv no seu respectivo diretório
echo $history | jq -r '.[] | [(.clock | tonumber | strftime("%d/%m/%Y")), (.clock | tonumber | strftime("%H:%M:%S")), .value] | @csv' | sed 's/"//g' > "${mount_directory}/spreadsheet.csv"
