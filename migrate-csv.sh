#!/bin/bash

INPUT=$1
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read source destination
do
    destination=$(echo $destination | sed 's/\r//g')
	echo "moving ${source} to ${destination}"
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

exit
