#!/bin/bash

# 1. Insert the bootable USB Drive with macOS image
# 2. Go to the recovery mode (Cmd-R or Hold-Power button)
# 3. Connect to the wifi
# 3. Launch the Terminal...

# Purge and format the main disk
diskutil eraseDisk APFS "Machintosh HD" /dev/disk0

# Reinstall macOS from the USB drive
/Volumes/macOS\ Base\ System/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall \
	--agreetolicense \
	--nointeraction \
	--forcequitapps \
	--volume /Volumes/Machintosh\ HD
