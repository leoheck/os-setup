#!/bin/bash


# Simple script to set hostname on macOS
# Leandro Sehnem Heck (leoheck@gmail.com)

# Usage: ./set-hostname.sh [HOSTNAME]

trap ctrl_c INT

function ctrl_c() {
	echo
	echo "Exiting... :)"
	exit 1
}

if [ $EUID != 0 ]; then
	echo
	echo "Running sudo, please type password for ${USER}"
	sudo touch /tmp/set-hostname
fi

hname="$1"

# Default hostname if it is not passed
if [[ "${hname}" == "" ]]; then
	serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d"=" -f2 | sed "s/\"//g" |sed "s/ //g")
	hname=${serial_number}
fi

echo
echo "Using '${hname}' as hostname"
echo
read -p 'Do you want to proceed? [y/N]: ' -n1 choice
echo
echo
if [[ "${choice}" != "y" ]]; then
	exit
fi

# Configure hostname
echo "Setting hostname ($hname)"
sudo scutil --set HostName ${hname}.local
sudo scutil --set ComputerName ${hname}
sudo scutil --set LocalHostName ${hname}
sudo dscacheutil -flushcache

# Enable remote login

echo "Enabling remote login (ssh)"
sudo systemsetup -f -setremotelogin on 1> /dev/null
sudo dseditgroup -o create -q com.apple.access_ssh
sudo dseditgroup -o edit -a admin -t group com.apple.access_ssh

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers 1> /dev/null

# Enable location tracking
echo "Enabling location tracking"

sudo defaults -currentHost write "com.apple.locationd" "LocationServicesEnabled" -int 1 1> /dev/null
sudo defaults -currentHost write "/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd" LocationServicesEnabled -int 1 1> /dev/null
sudo defaults -currentHost write "/Library/Preferences/com.apple.locationmenu" "ShowSystemServices" -bool YES 1> /dev/null

# Update things (hopefully)
sudo AssetCacheManagerUtil reloadSettings 2> /dev/null

echo "Done"
echo
