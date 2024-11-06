#!/bin/bash
#
#       Script de Backup Arquivos Nuvem AWS - Paralelismo Hosts
#
#Andrei Henrique Santos

# Carrega o arquivo de configuração
source config.sh

host=$1

# Define o limite de processos de itens paralelos (número máximo de processos de itens simultâneos)
max_itemsprocess=5
itemsprocess_number=0

hostname=$(echo "$host" | jq -r '.host')
hostid=$(echo "$host" | jq -r '.hostid')

# Realiza um requisição para receber os itens associados a um host específico e os salva em uma variável
items=$(./utils/zabbix-request.sh 2 $IP_ZABBIX $AUTH_TOKEN "item.get" "{\"output\": [\"itemid\", \"name\", \"value_type\"], \"hostids\": \"$hostid\"}" | jq -c '.result[]') 

# Inicia até "max_itemsprocess" de processos de itens simultâneos
echo "$items" | while read -r item; do

    # Inicia um processo de item em segundo plano
    ./utils/start-itemprocess.sh "$item" "$hostname" &
        
    # Aumenta o contador de processos de iten paralelos
    ((itemsprocess_number++))

    # Se o número de processos de itens paralelos atingir o limite, aguarda todos terminarem antes de inicar os próximos
    if ((itemsprocess_number >= max_itemsprocess)); then
        wait
        itemsprocess_number=0
    fi
done
