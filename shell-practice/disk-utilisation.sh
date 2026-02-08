#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DISK=$(df -hT | grep -v Filesystem )
USAGE_THRESHOLD=3
MESSAGE=""
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

log(){
    echo -e "$(date +%F-%H-%M-%S) | $1" | tee -a $LOGS_FILE 
}

while IFS= read -r line
do
    USAGE=$(echo $line | awk '{print $6}' | cut -d "%" -f1)
    PARTITION=$(echo $line | awk '{print $7}' | cut -d "%" -f1)

    if [ $USAGE -gt $USAGE_THRESHOLD ]; then
        MESSAGE+="High Disk Usage on $PARTITION: $USAGE% <br>"
    fi
done <<< $DISK


echo "$MESSAGE"

sh mail.sh "ayyappavedavyas.gudipati@gmail.com" "High Disk Usage Alert on $IP_ADDRESS" "$MESSAGE" "HIGH_DISK_USAGE" "$IP_ADDRESS" "DevOps Team"