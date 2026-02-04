#!/bin/bash

#-----------------VARIABLES------------------#
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

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
dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disable all NGINX Versions"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enable Nginx:1.24 Version"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "Start Nginx"

rm -rf /user/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "Removing Default Nginx Html Files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Frontend Code in ZIP Format"

cd /usr/share/nginx/html &>>$LOGS_FILE
VALIDATE $? "Changing Nginx frontend Directory"

unzip -o /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping  Frontend Code"

rm -rf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Removing All Configure Files"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Adding Custom Configure File"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restart Nginx"