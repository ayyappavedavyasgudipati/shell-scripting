#!/bin/bash

source ./common.sh

CHECK_ROOT

#--------------COMMANDS FOR DEPLOYMENT-----------------#
dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install Mysql - Server"

systemctl enable mysqld &>>$LOGS_FILE
VALIDATE $? "Enable Mysql"

systemctl start mysqld &>>$LOGS_FILE
VALIDATE $? "Start Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
VALIDATE $? "Adding Mysql System User"

PRINT_TOTAL_TIME