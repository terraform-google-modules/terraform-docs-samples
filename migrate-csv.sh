#!/bin/bash

# This makeshift script will take a csv file in the following format:
# source-directory-1,destination-directory-1
# source-directory-2,destination-directory-2
#
# Make sure that the csv fed into this script has no header, 
# and ends with a new line

# Formatting variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

INPUT=$1
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 1; }
while read source destination
do
   if [ ! -d "${source}" ]
   then
    echo "Directory ${source} does not exist. "
    echo "Make sure all directories in csv exist."
    exit 2
   fi;
done < $INPUT

while read source destination
do
    destination=$(echo $destination | sed 's/\r//g')
	echo -e "\n\xe2\x88\xb4 moving ${source} to ${destination}"
    git mv $source $destination
    git commit -m "move ${source} to ${destination}"
    saved=`git rev-parse HEAD`
    git reset --hard HEAD^
    git mv ${source} ${source}-copy
    git commit -m "temporary copy of ${source}"

    git merge $saved
    git commit -a -m "merge copy of ${source}"

    git mv ${source}-copy ${source}
    git commit -m "merge original copy of ${source}"
done < $INPUT