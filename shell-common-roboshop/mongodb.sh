#!/bin/bash

source ./common.sh

CHECK_ROOT

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

PRINT_TOTAL_TIME