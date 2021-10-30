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
	exit 1
fi

echo
echo sudo /usr/bin/dscl . -delete /Users/${username}
