#! /bin/bash
USERID=$(id -u) #if id -u = 0 then it is root user else non root user
LOGS_FOLDER="/var/log/shell-script" #creating a log folder path
LOGS_FILE="/var/log/shell-script/$0.log" #creating a log file and we can also use ="$LOGS_FOLDER/$0.log"
R="\e[31m" # theese are used to give colors for output text
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi
mkdir -p $LOGS_FOLDER

#PART2 is because we are calling this function in loop so it will run first the function run only when we call it
VALIDATE(){
    if [ $1 -ne 0 ]; then #from loop we get $1=0 so it goes to else
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else #from loop we get $2=nginx installation
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE #$2+" ... SUCCESS" = nginx instalation ...SUCCESS
    fi
}


#PART1
for package in $@ # sudo sh 14-loops.sh nginx mysql nodejs
do
    dnf list installed $package &>>$LOGS_FILE #LOGS_FILE is creating here
    if [ $? -ne 0 ]; then # here $? for suppose nginx not equal to '0' then it install nginx
        echo "$package not installed, installing now"
        dnf install $package -y &>>$LOGS_FILE
        VALIDATE $? "$package installation" #So at here we are getting $ ?= 0 and $2="pckage(nginx) installation->goes to function as arguments VALIDATE $1(0) $2(nginx)
    else
        echo -e "$package already installed ... $Y SKIPPING $N"
    fi
done