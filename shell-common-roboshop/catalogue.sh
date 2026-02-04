#!/bin/bash

source ./common.sh
APP_NAME=catalogue


CHECK_ROOT
#--------------COMMANDS FOR DEPLOYMENT-----------------#
APP_SETUP
NODEJS_SETUP
SYSTEM_SETUP

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

APP_RESTART
PRINT_TOTAL_TIME