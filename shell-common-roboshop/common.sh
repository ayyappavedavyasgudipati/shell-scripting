#!/bin/bash

#-----------------VARIABLES------------------#
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGO_HOST=mongodb.opswithvyas.online
MYSQL_HOST=mysql.opswithvyas.online

#-----------COLORS---------------------------#
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


#-------CHECKING WHETHER USER SWITCHED TO ROOT OR NOT--------#
CHECK_ROOT(){
    if [ $USERID -ne 0 ]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") | Please run the commands with root user access" | tee -a $LOGS_FILE
        exit 1
    fi
}

mkdir -p $LOGS_FOLDER

#------------FUNCTION TO CHECK STATUS OF DEPLOYMENT COMMANDS---------#
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1 
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 .....SUCCESS" | tee -a $LOGS_FILE
    fi    
}

NODEJS_SETUP(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disable all NodeJs Versions"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enable NodeJs:20 Version"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing NodeJs:20 Version"

    cd /app &>>$LOGS_FILE
    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing Packages"
}

APP_SETUP(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating System User roboshop"
    else
        echo -e "Roboshop user already exist ... $Y SKIPPING $N"
    fi   

    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading $APP_NAME code in ZIP format"

    cd /app &>>$LOGS_FILE
    VALIDATE $? "Opening app directory"

    rm -rf /app/* &>>$LOGS_FILE
    VALIDATE $? "Deleting any existing files in Directory"

    unzip /tmp/$APP_NAME.zip &>>$LOGS_FILE
    VALIDATE $? "Unzipping $APP_NAME Code to app Directory"
}

JAVA_SETUP(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Install Maven"

    cd /app &>>$LOGS_FILE
    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing Packages"

    mv target/$APP_NAME-1.0.jar $APP_NAME.jar &>>$LOGS_FILE
    VALIDATE $? "Renaming $APP_NAME.jar"
}

PYTHON_SETUP(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Install Python"

    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing Packages"
}

SYSTEM_SETUP(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service &>>$LOGS_FILE
    VALIDATE $? "Copying $APP_NAME Services"

    systemctl daemon-reload &>>$LOGS_FILE
    VALIDATE $? "Daemon Reloading"

    systemctl enable $APP_NAME &>>$LOGS_FILE
    VALIDATE $? "Enable $APP_NAME Service " 

    systemctl start $APP_NAME &>>$LOGS_FILE
    VALIDATE $? "Start $APP_NAME Service"
}

APP_RESTART(){
    systemctl restart $APP_NAME &>>$LOGS_FILE
    VALIDATE $? "Restart $APP_NAME Service"
}

PRINT_TOTAL_TIME(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script Executed in $G $TOTAL_TIME Seconds $N" | tee -a $LOGS_FILE
}