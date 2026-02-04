#!/bin/bash

source ./common.sh
APP_NAME=shipping

CHECK_ROOT
APP_SETUP
#--------------COMMANDS FOR INSTALLING MAVEN-----------------#
JAVA_SETUP
SYSTEM_SETUP

#-------------------INSTALLING MYSQL(mysql client)-------------------#
dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Install Mysql"

#---------------CONNECTING TO DATABASE AND CHECKING DATA IS ALREADY INSERTED OR NOT-----------------#
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOGS_FILE
VALIDATE $? "Connecting to MYSQL Database"
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 </app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 </app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 </app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Deploying Data"
else    
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

APP_RESTART
PRINT_TOTAL_TIME