#!/bin/bash
#
#       Script de Backup Arquivos Nuvem AWS
#
#Andrei Henrique Santos

id=$1
url_hostname=$2
token=$3
method=$4
params=$5

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
