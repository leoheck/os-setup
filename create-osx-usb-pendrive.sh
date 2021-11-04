#!/bin/bash

# Leandro Sehnem Heck (leoheck@gmail.com)

# How to create a bootable installer for macOS
# https://support.apple.com/en-us/HT201372

usbdrive="$1"

if [[ $usbdrive == "" ]]; then
	echo "Usage: $0 </Volumes/OSX>"
	exit 1
fi

if [[ ! -d $usbdrive ]]; then
	echo "The drive '$usbdrive' was not found!" 
	exit 1
fi

OSX_VERSION=$(sw_vers -productVersion | cut -d. -f1-2)

MONTEREY_VERSION=12.0
BIG_SUR_VERSION=11.4
CATALINA_VERSION=10.15
MOJAVE_VERSION=10.14
HIGH_SIERRA_VERSION=10.13

# softwareupdate --fetch-full-installer

if [[ -eq $OSX_VERSION $CATALINA_VERSION ]]; then
	# https://itunes.apple.com/us/app/macos-catalina/id1466841314?ls=1&mt=12
	sudo /Applications/Install\ macOS\ Catalina\ Beta.app/Contents/Resources/createinstallmedia --volume $usbdrive
fi

if [[ -eq $OSX_VERSION $MOJAVE_VERSION ]]; then
	# https://apps.apple.com/us/app/macos-mojave/id1398502828?ls=1&mt=12
	sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume $usbdrive
fi

if [[ -eq $OSX_VERSION $HIGH_SIERRA_VERSION ]]; then
	# https://apps.apple.com/us/app/macos-high-sierra/id1246284741?ls=1&mt=12
	sudo /Applications/Install\ macOS\ High\ Sierra.app/Contents/Resources/createinstallmedia --volume $usbdrive
fi

if [[ -eq $OSX_VERSION $BIG_SUR_VERSION ]]; then
	# https://apps.apple.com/us/app/macos-big-sur/id1526878132?mt=12
	sudo /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/createinstallmedia --volume $usbdrive
fi

if [[ -eq $OSX_VERSION $MONTEREY_VERSION ]]; then
	# https://apps.apple.com/us/app/macos-monterey/id1576738294?mt=12
	sudo /Applications/Install\ macOS\ Monterey.app/Contents/Resources/createinstallmedia --volume $usbdrive
fi
