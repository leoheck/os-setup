#!/bin/bash

# USAGE: ./delete-user.sh USERNAME

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
echo
echo "Running with sudo, please type password for ${USER}"
sudo touch /tmp/unlock_sudo
echo

sudo dscl . -delete /Users/${username}
sudo rm -rf /Users/${username}
