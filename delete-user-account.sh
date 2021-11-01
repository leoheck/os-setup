#!/bin/bash

username=$1

echo

if [[ ${username} = "" ]]; then
	echo -n "Type the username to be deleted: "
	read username
fi

echo -n "Are you sure you want to delete ${username} [y/N]?: "

read option

if [[ $option != "y" ]]; then
	echo "Alright, deletion aborted!"
	echo
	exit 1
fi

echo

# Ask for sudo password
sudo touch /tmp/create-new-user
echo

sudo dscl . -delete /Users/${username}
sudo rm -rf /Users/${username}
