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
    echo "Please run the commands with root user access" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

#------------FUNCTION TO CHECK STATUS OF DEPLOYMENT COMMANDS---------#
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1 
    else
        echo -e "$2 .....SUCCESS" | tee -a $LOGS_FILE
    fi    
}

#--------------COMMANDS FOR DEPLOYMENT-----------------#
dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disable all NodeJs Versions"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable NodeJs:20 Version"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing NodeJs:20 Version"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating System User roboshop"
 else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N" &>>$LOGS_FILE
fi   

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Cart code in ZIP format"

cd /app &>>$LOGS_FILE
VALIDATE $? "Opening app directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Deleting any existing files in Directory"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping Cart Code to app Directory"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing Packages"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOGS_FILE
VALIDATE $? "Copying Cart Services"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Daemon Reloading"

systemctl enable cart &>>$LOGS_FILE
systemctl start cart &>>$LOGS_FILE
VALIDATE $? "Start Cart Service"
