#!/bin/bash
#
#	Script de Backup Arquivos Nuvem AWS
#
#Andrei Henrique Santos

AUTH_TOKEN=seu-token
IP_ZABBIX=ip-do-seu-zabbix
BUCKET_S3="seu-bucket"

current_time=$(date +%s)
month_ago=$(date -d "1 month ago" +%s)

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

hosts=$(zabbix_request 1 $IP_ZABBIX $AUTH_TOKEN "template.get" '{"output": "hosts","templateids": "10638","selectHosts": ["hostid", "host"]}' | jq -c '.result[] | .hosts[]')

echo "${hosts}" | while read -r host; do
    hostid=$(echo "$host" | jq -r '.hostid')
    hostname=$(echo "$host" | jq -r '.host')

    echo "Host Name: $hostname"

    itens=$(zabbix_request 2 $IP_ZABBIX $AUTH_TOKEN "item.get" "{\"output\": [\"itemid\", \"name\", \"value_type\"], \"hostids\": \"$hostid\"}" | jq -c '.result[]') 

    echo "${itens}" | while read -r item; do

        itemid=$(echo "$item" | jq -r '.itemid')
        itemname=$(echo "$item" | jq -r '.name')
        itemvaluetype=$(echo "$item" | jq -r '.value_type')

        echo "	Item Name: $itemname"

        history=$(zabbix_request 3 $IP_ZABBIX $AUTH_TOKEN "history.get" "{\"output\": [\"clock\", \"value\"], \"history\": \"$itemvaluetype\", \"itemids\": \"$itemid\", \"sortfield\": \"clock\", \"sortorder\": \"ASC\", \"time_from\": \"$month_ago\", \"time_till\": \"$current_time\"}" | jq -c '.result[]')

        mount_directory="/tmp/upload_cloud/logs/$(date +%Y)/$(date +%B)/${hostname}/${itemname}/"
        mkdir -p "${mount_directory}" 
        echo $history | jq . > "${mount_directory}/values.txt"
    done
done

aws s3 cp "/tmp/upload_cloud/" "s3://${BUCKET_S3}/" --recursive
