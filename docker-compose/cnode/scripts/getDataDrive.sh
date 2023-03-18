#!/bin/bash
if [ $# != 2 ]; then
   echo "Usage: ~/.scripts/getDataDrive.sh file_id file_name"
   exit 0
fi
#-- db epoch 265
#file_id="1nxMN-npizmwNTXHrf0Rfhee-3nukaKpz"
#$file_name="db.zip"
#
#-- bin 1.27.0
#$file_id="17uLzmtlpQbKsWnrgKGHd8PUvu9qI1PoT"
#-- bin 1.26.2
#$file_id="1y1ZBVXGInMJ8F2X8wVQ47ZvIgY8CEFFi"
#$file_name="bin.zip"
#
curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=$1" > /dev/null
curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=$1" -o $2
