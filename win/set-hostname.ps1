#!/bin/bash

# Simple script to set hostname on windows (powershell)
# Leandro Sehnem Heck (leoheck@gmail.com)

# Usage: ./set-hostname.ps [HOSTNAME]

$hostname=$args[0]


if($hostname -eq $null)
{
	# Serial Number (Service Tag)
	echo "Setting hostname as $serial_number ..." 
	$serial_number = (gwmi win32_bios).SerialNumber
	Rename-Computer -NewName "$serial_number"
} 
else 
{
	echo "Setting hostname as $hostname ..." 
	Rename-Computer -NewName "$hostname"
}
