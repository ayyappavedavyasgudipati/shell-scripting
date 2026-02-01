#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo -e "Please use root access to continue"
    exit 1
fi

mkdir -p $LOGS_FOLDER


VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "$2 installation failed"
        exit 1
    else 
        echo "$2 installation success"
    fi
}


for package in $@
do
    dnf list installed $package
    if [ $? -ne 0 ]; then
        dnf install $package -y
        echo "$package not installed installing now"
        VALIDATE $? "$package installing.. " 
    else
        echo "package already there"
        
    fi
done