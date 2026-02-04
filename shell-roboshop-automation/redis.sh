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
dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disable Redis All Versions"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enable Redis:7 Version"

dnf install redis -y  &>>$LOGS_FILE
VALIDATE $? "Install Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "Modifying redis.conf 127.0.0.1  To  0.0.0.0 and Protected Mode - NO"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enable Redis"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Start Redis"