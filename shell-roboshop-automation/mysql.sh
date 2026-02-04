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
        echo -e "$2  ....FAILURE" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 .....SUCCESS" | tee -a $LOGS_FILE
    fi    
}

#--------------COMMANDS FOR DEPLOYMENT-----------------#
dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install Mysql - Server"

systemctl enable mysqld &>>$LOGS_FILE
VALIDATE $? "Enable Mysql"

systemctl start mysqld &>>$LOGS_FILE
VALIDATE $? "Start Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
VALIDATE $? "Adding Mysql System User"