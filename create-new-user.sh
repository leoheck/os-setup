#!/bin/bash

# Usage: ./create-new-user.sh FIRST_NAME [LAST_NAME] [HOSTNAME] [PASSWORD]

first_name=$1
last_name=$2

# Ask for sudo password
echo
echo "Running with sudo, please type password for ${USER}"
sudo touch /tmp/create-new-user
echo

if [[ ${first_name} = "" || ${last_name} = "" ]]; then
	echo -n "Type the first name: "
	read first_name
	echo -n "Type the last name: "
	read last_name
	echo
fi

# Force name to be Title Case
first_name=$(echo "${first_name}" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
last_name=$(echo "${last_name}"   | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')

full_name="${first_name} ${last_name}"

# Custom Hostname
if [[ $3 = "" ]]; then
	first_name_first_letter=$(echo ${first_name} | cut -c 1 | tr '[:upper:]' '[:lower:]')
	last_name_lowercase=$(echo ${last_name} | tr '[:upper:]' '[:lower:]')
	username="${first_name_first_letter}${last_name_lowercase}"
else
	username=$3
fi

# Custom Password
if [[ $4 = "" ]]; then
	password="ChangeMeAsSoonAsPossible"
else
	password=$4
fi

# List users IDs
# dscl . -list /Users UniqueID

LastUsedID=$(dscl . -list /Users UniqueID | grep -v "^_" | sed -e "s/  */ /g" | sort -k2 | cut -d" " -f2 | tail -1)
UniqueUserID=$((LastUsedID+1))

echo "SUMMARY"
echo
echo "   Full name = ${full_name}"
echo "    username = ${username}"
echo "    password = ${password}"
echo "    UniqueID = ${UniqueUserID}"
echo "  LastUsedID = ${LastUsedID}"
echo
echo -n "Proceed with '${first_name} ${last_name} ($username)'? [y/N]: "
read choice

if [[ ${choice} != "y" && ${choice} != "Y" ]]; then
	echo "Alright, creation aborted!"
	echo
	exit 1
fi

sudo dscl . -create /Users/${username}
sudo dscl . -create /Users/${username} UserShell /bin/zsh
sudo dscl . -create /Users/${username} RealName "${full_name}"
sudo dscl . -create /Users/${username} UniqueID ${UniqueUserID}
sudo dscl . -create /Users/${username} PrimaryGroupID 1000
sudo dscl . -create /Users/${username} NFSHomeDirectory /Users/${username}
sudo dscl . -passwd /Users/${username} "${password}"
sudo dscl . -append /Groups/admin GroupMembership ${username}

# Set a initial picture
sudo dscl . delete /Users/${username} JPEGPhoto
sudo dscl . create /Users/${username} Picture "/Library/User Pictures/Animals/Eagle.tif"

# Finish by setting hostname and enable location services
#./set-hostname.sh ${username}

# Update things (hopefully)
sudo AssetCacheManagerUtil reloadSettings 1> /dev/null

echo "DONE, user ${full_name} created."
echo
echo "Better to reboot once"
echo