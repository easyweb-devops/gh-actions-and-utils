#!/usr/bin/env bash
if ! command -v jq &> /dev/null
then
  apt-get install jq
fi

DO_TOKEN=$1
ENV=$2
USER=$3

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DO_TOKEN" "https://api.digitalocean.com/v2/droplets?tag_name=$ENV" > ips.json
jq -r '.droplets[].networks.v4[] | select(.type == "public") | .ip_address' "ips.json" > ip.txt
rm ips.json

touch hosts
echo "[servers]" >> hosts
while IFS= read -r line
do
  echo "$line:22 ansible_ssh_port=22 ansible_connection=ssh ansible_ssh_private_key_file=~/.ssh/$USER ansible_ssh_user=$USER" >> hosts
done < ip.txt

cat hosts
