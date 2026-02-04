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

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
VALIDATE $? "Adding User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "Set Permissions for User"

systemctl restart rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Restart RabbitMQ"

PRINT_TOTAL_TIME