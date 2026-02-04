#!/bin/bash

#-----------------VARIABLES------------------#
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGO_HOST=mongodb.opswithvyas.online

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
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi   

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Catalogue code in ZIP format"

cd /app &>>$LOGS_FILE
VALIDATE $? "Opening app directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Deleting any existing files in Directory"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping catalogue Code to app Directory"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing Packages"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGS_FILE
VALIDATE $? "Copying Catalogue Services"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Daemon Reloading"

systemctl enable catalogue &>>$LOGS_FILE
VALIDATE $? "Enable Catalogue Service " 

#-------------------INSTALLING MONGOSH(mongodb client)-------------------#
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Adding MongoDB Repo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB"

#---------------CONNECTING TO DATABASE AND CHECKING DATA IS ALREADY INSERTED OR NOT-----------------#
INDEX=$(mongosh --host $MONGO_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>>$LOGS_FILE
VALIDATE $? "Connecting MongoDB"
if [ $INDEX -ne 0 ]; then
    mongosh --host $MONGO_HOST </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Adding MongoDB Products"
else
    echo "Products already loaded $Y....SKIPPING$N"
fi

systemctl start catalogue &>>$LOGS_FILE
VALIDATE $? "Start Catalogue Service"

systemctl restart catalogue &>>$LOGS_FILE
VALIDATE $? "Restart Catalogue Service"