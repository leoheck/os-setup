#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
else
	sudo ./create-new-user.sh $@
fi

first_name=$1
last_name=$2

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

echo "SUMARRY"
echo
echo " Full name = ${full_name}"
echo "  username = ${username}"
echo "  password = ${password}"
echo
echo -n "Proceed with '${first_name} ${last_name} ($username)'? [y/N]: "
read choice

if [[ ${choice} != "y" && ${choice} != "Y" ]]; then
	echo "Alright, creation aborted!"
	echo
	exit 1
fi

sudo dscl . -create /Users/${username}
sudo dscl . -create /Users/${username} UserShell /bin/bash
sudo dscl . -create /Users/${username} RealName "${full_name}"
sudo dscl . -create /Users/${username} UniqueID 503
sudo dscl . -create /Users/${username} PrimaryGroupID 1000
sudo dscl . -create /Users/${username} NFSHomeDirectory /Local/Users/${username}
sudo dscl . -passwd /Users/${username} "${password}"
sudo dscl . -append /Groups/admin GroupMembership ${username}

# Finish by setting hostname and enable location services
#./set-hostname.sh ${username}

# Reboot to validate
#sudo reboot
echo "Reboot computer for the changes to take effect"
echo
