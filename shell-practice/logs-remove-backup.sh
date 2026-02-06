#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/backup.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} # 14 days is the default value, if the user not supplied
SOURCE_BASENAME=$(basename "$SOURCE_DIR")


log(){
    echo -e "$(date +%F-%H-%M-%S) | $1" | tee -a $LOGS_FILE 
}

if [ $USERID -ne 0 ]; then
    log "$R Please use root access to continue $N"
    exit 1
fi

mkdir -p $LOGS_FOLDER

if [ $# -lt 2 ]; then
    log "$R Need 2 Arguments - backup <SOURCE_DIR> <DEST_DIR> <DAYS>[default 14 days] $N"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    log "$R Source Directory $SOURCE_DIR does not exist $N"
    exit 1
fi    

if [ ! -d "$DEST_DIR" ]; then
    log "$R Destination Directory $DEST_DIR does not exist $N"
    exit 1
fi  

OLD_LOG_FILES=$(find "$SOURCE_DIR" -name "*.log" -type f -mtime +$DAYS)

log "Backup started"
log "Source Directory: $SOURCE_DIR"
log "Destination Directory: $DEST_DIR"
log "Days: $DAYS"



if [ -z "$OLD_LOG_FILES" ]; then
    log "There is no log files to Delete  .... $Y SKIPPING $N"
    exit 1
else
    log "Files found to archive : $OLD_LOG_FILES"
    TIMESTAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/${SOURCE_BASENAME}-app-log-$TIMESTAMP.tar.gz"
    log "Archieve name: $ZIP_FILE"
    tar -zcvf $ZIP_FILE $OLD_LOG_FILES

    if [ -f $ZIP_FILE ]; then
        log "Archeival is ... $G SUCCESS $N"

        while IFS= read -r filepath; do
        # Process each line here
        log "Deleting file: $filepath"
        rm -f $filepath
        log "Deleted file: $filepath"
        done <<< $OLD_LOG_FILES
    else
        log "Archeival is ... $R FAILURE $N"
        exit 1
    fi
fi    


