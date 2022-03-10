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
	Rename-Computer -ComputerName "$serial_number" -NewName "$serial_number" -LocalCredential RemoteComputerAdminUser -Restart
} 
else 
{
	echo "Setting hostname as $hostname ..." 
	Rename-Computer -ComputerName "$hostname" -NewName "$hostname" -LocalCredential RemoteComputerAdminUser -Restart
}
