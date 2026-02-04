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

START_TIME=$(date +%s)
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


PRINT_TOTAL_TIME(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$($END_TIME-$START_TIME)
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script Executed in $G $TOTAL_TIME Seconds $N" | tee -a $LOGS_FILE
}