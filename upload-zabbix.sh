#!/bin/bash
#
#	Script de Backup Arquivos Nuvem AWS
#
#Andrei Henrique Santos

# Verificação se todos os argumentos foram passados na execução do script
if [ $# -eq 4 ]; then
    # Adiciona os argumentos em suas respectivas variáveis
    AUTH_TOKEN=$1
    IP_ZABBIX=$2
    BUCKET_S3=$3
    TEMPLATE_ID=$4

    # Cria ou sobrescreve o arquivo de configuração
    echo -e "# Arquivo de configuração\nAUTH_TOKEN=\"$AUTH_TOKEN\"\nIP_ZABBIX=\"$IP_ZABBIX\"\nBUCKET_S3=\"$BUCKET_S3\"\nTEMPLATE_ID=\"$TEMPLATE_ID\"" > config.sh 

else
    # Verifica se o arquivo de configuração já existe
    if [ ! -e "config.sh" ]; then
       echo "Para rodar este script é necessário enviar os seguintes argumentos: "
       echo "./upload-zabbix.sh <token-zabbix> <ip-zabbix> <nome-buckets3> <template-id>"
       exit 1
    fi

    # Carrega o arquivo de configuração
    source config.sh
fi

# Realiza um requisição para receber os hosts associados a um template específico e os salva em uma variável 
hosts=$(./utils/zabbix-request.sh 1 $IP_ZABBIX $AUTH_TOKEN "template.get" "{\"output\": \"hosts\",\"templateids\": \"$TEMPLATE_ID\",\"selectHosts\": [\"hostid\", \"host\"]}" | jq -c '.result[] | .hosts[]')

# Define o limite de hosts paralelos (rodando ao mesmo tempo)
max_hosts=5
hosts_number=0

# Inicia até "max_hosts" de hosts simultâneos 
echo "$hosts" | while read -r host; do

    # Inicia um host em segundo plano
    ./utils/start-host.sh "$host" &

    # Aumenta o contador de hosts paralelos
    ((hosts_number++))

    # Se o número de hosts paralelos atingir o limite, aguarda todos terminarem antes de inicar os próximos
    if ((hosts_number >= max_hosts)); then
        wait
        hosts_number=0
    fi
done

# Aguarda todos os processos terminarem
wait

# Envia todos os arquivos dentro da pasta "/tmp/upload-cloud" junto com seus respectivos diretórios em um Bucket S3 da AWS
aws s3 cp "/tmp/upload_cloud/" "s3://${BUCKET_S3}/" --recursive
