#!/bin/bash

# Improved 2021-07-06

# Simple script to initialize a new MAC
# Leandro Sehnem Heck (leoheck@gmail.com)

trap ctrl_c INT

function ctrl_c() {
	echo
	echo "Exiting... :)"
	exit 1
}

if [ $EUID != 0 ]; then
	echo
	echo "Running sudo, please type password for ${USER}"
	sudo "$0" "$@"
	exit $?
fi

hname="$1"

# Default hostname if it is not passed
if [[ "${hname}" == "" ]]; then
	hname="mbp-$(date +'%Y-%m-%d-%H-%M-%S')"
fi

echo
echo "Using '${hname}' as hostname"
echo "Otherwise run it as: $0 USERNAME"
echo
read -p 'Do you want to proceed? [y/N]: ' -n1 proceed
echo
echo
if [[ "${proceed}" != "y" ]]; then
	exit
fi

# Configure hostname
echo "Setting hostname ($hname)"
sudo scutil --set HostName ${hname}.local
sudo scutil --set ComputerName ${hname}
sudo scutil --set LocalHostName ${hname}
dscacheutil -flushcache

# Enable remote login
echo "Enabling remote login"
sudo  systemsetup -f -setremotelogin on 1> /dev/null
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
     -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers 1> /dev/null

# Enable location tracking
echo "Enabling location tracking"
sudo -u _locationd /usr/bin/defaults -currentHost write com.apple.locationd LocationServicesEnabled -int 1 1> /dev/null
sudo /usr/bin/defaults -currentHost write /Library/Preferences/com.apple.locationmenu "ShowSystemServices" -bool YES 1> /dev/null

echo "Done"
echo
