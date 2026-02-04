#!/bin/bash

#-----------------VARIABLES------------------#
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

#-----------COLORS---------------------------#
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#-------CHECKING WHETHER USER SWITCHED TO ROOT OR NOT--------#
if [ $USERID -ne 0 ]; then
    echo -e "Please run the commands with root user access" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

#------------FUNCTION TO CHECK STATUS OF DEPLOYMENT COMMANDS---------#
VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$2  ....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N" | tee -a $LOGS_FILE
    fi    
}

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