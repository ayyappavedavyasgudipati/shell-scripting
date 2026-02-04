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
    echo "Please run the commands with root user access" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

#------------FUNCTION TO CHECK STATUS OF DEPLOYMENT COMMANDS---------#
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....FAILURE" | tee -a $LOGS_FILE
        exit 1 
    else
        echo -e "$2 .....SUCCESS" | tee -a $LOGS_FILE
    fi    
}

#--------------COMMANDS FOR DEPLOYMENT-----------------#
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Install MongoDB Server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable Mongo"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Start Mongo"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Modifying mongod.conf 127.0.0.1  To  0.0.0.0"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restart Mongo"