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
dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "Install Maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Adding System User"
else 
    echo -e "Roboshop User Already Added"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Shpping Code in Zop Format"

cd /app &>>$LOGS_FILE
VALIDATE $? "Changing to app Directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing All Files in app Directory"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping Shipping Code in app Directory"

mvn clean package &>>$LOGS_FILE
VALIDATE $? "Installing Packages"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "Renaming shipping.jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILE
VALIDATE $? "Copying Shipping Services"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Daemon Reload"

#-------------------INSTALLING MYSQL(mysql client)-------------------#
dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Install Mysql"

#---------------CONNECTING TO DATABASE AND CHECKING DATA IS ALREADY INSERTED OR NOT-----------------#
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Deploying Data"
else    
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOGS_FILE
VALIDATE $? "Enable Shipping Service"

systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "Start Shipping Service"