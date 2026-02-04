#!/bin/bash

source ./common.sh


CHECK_ROOT

#--------------COMMANDS FOR DEPLOYMENT-----------------#
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "Copying RabbitMQ Repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Install RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Enable RabbitMQ"

systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Start RabbitMQ"

rabbitmqctl list_users | grep -w roboshop &>>$LOGS_FILE
VALIDATE $? "Checking User Already exist or not"
 
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
    VALIDATE $? "Adding User"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
    VALIDATE $? "Set Permissions for User"
else 
    echo "User Already Added   ....$Y SKIPPING $N"    
fi

systemctl restart rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Restart RabbitMQ"

PRINT_TOTAL_TIME