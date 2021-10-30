#!/bin/bash

name=$1 
surname=$2

echo

if [[ ${name} = "" || ${surname} = "" ]]; then
	echo -n "Type the main name: "
	read name
	echo -n "Type the surname: "
	read surname
	echo
fi

echo -n "Proceed with '${name^} ${surname^}'? [y/N]: "
read option

if [[ $option != "y" ]]; then
	echo "Alright, creation aborted!"
	exit 1
fi

echo

# name="Felipe"
# surname="Rios"

password="ChangeMeAsSoonAsPossible"

full_name="${name^} ${surname^}"

name_lowercase=${name,,}
surname_lowercase=${surname,,}
username="${name_lowercase:0:1}${surname_lowercase}"

echo
echo " Full name = ${full_name}"
echo "  username = ${username}"
echo "  password = ${password}"
echo

echo "Hit enter to continue, otherwise Ctrl+C to leave"
read

sudo dscl . -create /Users/${username}
sudo dscl . -create /Users/${username} UserShell /bin/zsh
sudo dscl . -create /Users/${username} RealName "${full_name}"
sudo dscl . -create /Users/${username} UniqueID 1001
sudo dscl . -create /Users/${username} PrimaryGroupID 1000
sudo dscl . -create /Users/${username} NFSHomeDirectory /Local/Users/${username}
sudo dscl . -passwd /Users/${username} ${password}
sudo dscl . -append /Groups/admin GroupMembership ${username}

./set-hostname ${username}
