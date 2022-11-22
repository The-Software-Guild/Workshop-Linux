#!/bin/sh

# what is 2> /dev/null ?
mkdir logs 2> /dev/null

while true
do 
	echo "logging data.." >> logs/file.$(date +"%Y-%m-%d-%T").log
    sleep 30 
done
