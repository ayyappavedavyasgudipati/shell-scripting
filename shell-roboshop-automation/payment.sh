#!/bin/bash

#-----------------VARIABLES------------------#
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.opswithvyas.online

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
dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Install Python"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Adding System User"
else 
    echo -e "Roboshop User Already Added"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app Directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading Payment Code in Zip Format"

cd /app 
VALIDATE $? "Opening App Directory" &>>$LOGS_FILE

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing All Files in app Directory"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping Payment Code"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing Packages"
                                
cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATE $? "copying Payment Service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Daemon Reloading"

systemctl enable payment &>>$LOGS_FILE
systemctl start payment &>>$LOGS_FILE
VALIDATE $? "Start Payment Service"