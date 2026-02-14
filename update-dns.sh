#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/update-dns.conf"
IP_FILE="$SCRIPT_DIR/ip.txt"

# Load config
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Config not found: $CONFIG_FILE" >&2
  exit 1
fi

# Load old IP
if [[ -f "$IP_FILE" ]]; then
    OLD_IP=$(cat $IP_FILE | tr -d '\n')
else
    OLD_IP="0.0.0.0"
fi

IP=$(curl -s "https://ifconfig.me")
echo $IP > $IP_FILE

if [[ "$OLD_IP" = "$IP" ]]; then
    echo "IP has not changed: $IP"
    exit 0
fi

if [[ $OLD_IP = "0.0.0.0" ]]; then
    echo "First run. Updating DNS with IP $IP."
else
    echo "IP has changed from $OLD_IP to $IP. Updating DNS."
fi

for DOMAIN in "${DOMAINS[@]}"; do
    echo "Updating domain $DOMAIN"
    aws route53 change-resource-record-sets \
      --no-cli-pager \
      --hosted-zone-id $ZONE_ID \
      --change-batch "{
        \"Changes\": [
          {
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
              \"Name\":\"${DOMAIN}\",
              \"Type\":\"A\",
              \"TTL\":300,
              \"ResourceRecords\":[{\"Value\":\"${IP}\"}]
            }
          }
        ]
      }"
done
