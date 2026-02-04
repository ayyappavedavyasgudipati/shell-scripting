#!/bin/bash

SG_ID="sg-08ead4da4a18d399e"
AMI_ID="ami-0220d79f3f480ecf5"
INSTANCE_TYPE="t3.micro"
ZONEID="Z10201011EZM611L941TT"
DNS="opswithvyas.online"


for INSTANCE in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
    --query 'Instances[0].InstanceId' \
    --output text)


    if [ $INSTANCE == "frontend" ]; then
        echo "$INSTANCE PUBLIC IP"
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text) 

        RECORD_NAME="$DNS"    
    else 
        echo "$INSTANCE PRIVATE IP"
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text) 
        RECORD_NAME="$INSTANCE.$DNS"       
    fi 

    echo "$IP"      

     aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

    echo "record updated for $INSTANCE"

done