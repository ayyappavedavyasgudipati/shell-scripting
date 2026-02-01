#!/bin/bash

SG_ID="sg-08ead4da4a18d399e"
AMI_ID="ami-0220d79f3f480ecf5"
INSTANCE_TYPE="t3.micro"


for INSTANCE in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $INSTANCE \
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
    else 
        echo "$INSTANCE PRIVATE IP"
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)  
    fi               
done