#!/bin/bash

#--------------CREATING DIRECTORY AND FILES-------------
DIR=/home/ec2-user/app-logs
FILES="$DIR/$0.log"
$HOME=$PWD


#--------------CREATING FILES AND DIRECTORY WITH BACK DATE-----------

mkdir -p $DIR
cd $DIR
touch -d 20260101 user.log cart.log catalogue.lo
ls -l

cd $HOME
if [ ! -d $DIR ]; then
    echo "$DIR is not existed"
    exit 1
fi

FILES_TO_DELETE=$(find $DIR -name "*.log" -type f -mtime +14)

while IFS= read -r filepath; do
    # Process the line here
    echo "$(date "+%Y-%m-%d %H:%M:%S") | Deleting file : $filepath"
    rm -rf $filepath
    sleep 1
    echo "$(date "+%Y-%m-%d %H:%M:%S") | Deleted file : $filepath"
done <<< $FILES_TO_DELETE