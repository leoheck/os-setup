#!/bin/bash

# Leandro Sehnem Heck (leoheck@gmail.com)

# USAGE: 
# ./new-user "Nome Completo" "username"

hname="$1"

if [[ "$hname" == "" ]]; then
	export hname="mbp-$(date +'%Y-%m-%d-%H-%M-%S')"
fi

parse_command_line()
{

}

confirm_user_info_to_proceed()
{
	#echo "Using '$hname' as hostname"
	#read 
}

enable_terminal_full_disk_access()
{
	#https://developer.apple.com/documentation/devicemanagement/privacypreferencespolicycontrol
}

detect_os_version()
{

}

create_new_user()
{
	# create new user
	# set default password
	# expire password after first enable_remote_login
	# set user as admin
}

set_zsh_shell()
{
	# BOTH for poaoffice and for the new user
	# set (force) zsh as default
	# install ohmyzsh, 
}

set_hostname()
{
	# Configure hostname
	sudo scutil --set HostName $hname.local
	sudo scutil --set ComputerName $hname
	sudo scutil --set LocalHostName $hname
	dscacheutil -flushcache
}

# systemsetup -setremotelogin -setremoteappleevents

enable_remote_login()
{
	sudo systemsetup -f -setremotelogin on
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
	     -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
}

enable_location_services()
{
	sudo -u _locationd /usr/bin/defaults -currentHost write com.apple.locationd LocationServicesEnabled -int 1
	sudo /usr/bin/defaults -currentHost write /Library/Preferences/com.apple.locationmenu "ShowSystemServices" -bool YES
}

show_important_info()
{
	# present username and Full Name
	# present hostname
	# present initial password
}



parse_command_line
confirm_user_info_to_proceed
enable_terminal_full_disk_access
detect_os_version
create_new_user
set_zsh_shell
set_hostname
enable_remote_login
enable_location_services
upgrade_os
install_xcode
