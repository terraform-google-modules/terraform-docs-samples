#!/bin/bash

# This makeshift script will take a csv file in the following format:
# source,destination
# source-directory-1,destination-directory-1
# source-directory-2,destination-directory-2

# Formatting variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
ARROW='\033[0;32m\xe2\x89\xab'

INPUT=$1
IFS=','
[ ! -f $INPUT ] && {
    echo "$INPUT file not found"
    exit 1
}

echo -e "${GREEN}Preview:\n${NC}"
count=0
{
    read
    while read source destination || [ -n "${source}" ] && [ -n "${destination}" ]; do
        if [ ! -d "${source}" ]; then
            echo -e "---\n${RED}Error:${NC} Directory ${RED}${source} ${NC}does not exist. Make sure all directories in csv exist. \n---"
            exit 2
        fi
        echo -e "${ARROW} ./${source}${NC} will be copied to ${GREEN}./${destination}${NC}"
        let count+=1
    done
} <$INPUT
echo -e "\n${GREEN}Number of samples to be copied: ${count}${NC} \n---"

read -p "Continue? (y/n)" continue
case "$continue" in
y | Y) echo -e "Continuing...\n" ;;
n | N) exit 0 ;;
*) echo "invalid" && exit 1 ;;
esac
{
    read
    while read source destination || [ -n "${source}" ] && [ -n "${destination}" ]; do
        # Remove carriage return from destination variable
        destination=$(echo $destination | sed 's/\r//g')
        # Create target directory
        mkdir -p $(dirname $destination)
        # Move sample to destination and commit
        echo -e "\n\xe2\x88\xb4 Moving ${GREEN}${source}${NC} to ${GREEN}${destination}${NC}\n"
        git mv $source $destination
        git commit -m "move ${source} to ${destination}"
        echo -e "\n"
        # Save the ID of the revision with the moved sample for use later in merge
        saved=$(git rev-parse HEAD)
        # Reset to HEAD, temporarily rename source, and commit
        git reset --hard HEAD^
        git mv ${source} ${source}-copy
        echo -e "\n"
        git commit -m "temporary copy of ${source}"
        # Merge current with saved revision and commit
        echo -e "\n"
        git merge $saved
        echo -e "\n"
        git commit -a -m "merge copy of ${source}"
        # Rename source back to original name and commit
        git mv ${source}-copy ${source}
        echo -e "\n"
        git commit -m "merge original copy of ${source}"
    done
} <$INPUT
