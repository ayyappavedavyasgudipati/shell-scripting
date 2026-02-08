#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DISK=$(df -hT | grep -v Filesystem )
USAGE_THRESHOLD=3
MESSAGE=""

log(){
    echo -e "$(date +%F-%H-%M-%S) | $1" | tee -a $LOGS_FILE 
}

while IFS= read -r line
do
    USAGE=$(echo $line | awk '{print $6}' | cut -d "%" -f1)        #need echo because that line is not a command its a string.
    PARTITION=$(echo $line | awk '{print $7}' | cut -d "%" -f1)

    if [ $USAGE -gt $USAGE_THRESHOLD ]; then
        MESSAGE+="High Disk Usage on $PARTITION: $USAGE% \n"
        echo "$MESSAGE"
    fi
done <<< $DISK