#!/bin/bash

first_name=$1 
last_name=$2
username=$2

echo

if [[ ${first_name} = "" || ${last_name} = "" ]]; then
	echo -n "Type the first name: "
	read first_name
	echo -n "Type the last name: "
	read last_name
	echo
fi

# Force name to be Title Case
first_name=$(echo "${first_name}" | sed 's/[^ ]\+/\L\u&/g')
last_name=$(echo "${last_name}"  | sed 's/[^ ]\+/\L\u&/g')

full_name="${first_name} ${last_name}"

if [[ $3 = "" ]]; then
	first_name_first_letter=$(echo ${first_name} | cut -c1 | sed 's/.*/\L&/')
	last_name_lowercase=$(echo ${last_name} | sed 's/.*/\L&/')
	username="${first_name_first_letter}${last_name_lowercase}"
fi

password="ChangeMeAsSoonAsPossible"

echo "SUMARRY"
echo
echo " Full name = ${full_name}"
echo "  username = ${username}"
echo "  password = ${password}"
echo
echo -n "Proceed with '${first_name} ${last_name} ($username)'? [y/N]: "
read option

if [[ $option != "y" ]]; then
	echo "Alright, creation aborted!"
	echo
	exit 1
fi

sudo dscl . -create /Users/${username}
sudo dscl . -create /Users/${username} UserShell /bin/bash
sudo dscl . -create /Users/${username} RealName "${full_name}"
sudo dscl . -create /Users/${username} UniqueID 1001
sudo dscl . -create /Users/${username} PrimaryGroupID 1000
sudo dscl . -create /Users/${username} NFSHomeDirectory /Local/Users/${username}
sudo dscl . -passwd /Users/${username} "${password}"
sudo dscl . -append /Groups/admin GroupMembership ${username}

# Finish by setting hostname and enable location services
./set-hostname.sh ${username}
