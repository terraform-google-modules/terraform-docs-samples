#!/bin/bash

source=${1%/}
destination=${2%/}

if [ ! -d "$source" ]; then
    echo "Source \"${source}\" does not exist"
    exit 2
fi

echo "Moving ${source} to ${destination}"

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