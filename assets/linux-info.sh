#!/bin/bash

# Serial Number
# Model
# Model Year
# Waranty?

# Processor
# Disk
# Memory
# Graphics card

#serial_number=$(sudo dmidecode -t 1 | grep "Serial Number" | cut -d: -f2 | sed "s/^[ \t]\+//g")
#model_number=$( sudo dmidecode -t 1 | grep "Product Name"  | cut -d: -f2 | sed "s/^[ \t]\+//g")

serial_number=$(sudo dmidecode -s system-serial-number)
model_number=$(sudo dmidecode -s system-product-name)

# Memory
memory_size=$(free --gibi | grep Mem | sed "s/[ \t]\+/ /g" | cut -d" " -f2)
# Better information here
# sudo dmidecode -t 17
# sudo dmidecode -t 19

processor=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")
n_cpus=$(echo $(cat /proc/cpuinfo | grep "processor" | tail -1 | cut -d: -f2 | sed "s/^[ ]\+//g")+1 | bc)
n_cores=$(cat /proc/cpuinfo | grep "cpu cores" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")

# Battery info
# sudo dmidecode -t 22

disk_size=$(sudo fdisk -l /dev/nvme0n1 | grep -m1 "Disk" | cut -d" " -f3)

gpu=$(lspci | grep -i nvidia | grep "3D controller" | cut -d: -f3 | sed "s/^[ ]\+//g")

echo
echo "Serial Number: ${serial_number}"
echo "        Model: ${model_number}"
echo "         Year: ${year}"
echo "    Processor: ${processor}"
echo "         CPUs: ${n_cpus}"
echo "        Cores: ${n_cores}"
echo "       Memory: ${memory_size} GB"
echo "          GPU: ${gpu}"
echo "    Disk Size: ${disk_size} GB"
echo
echo

# DEMIDECODE
#  0 BIOS
#  1 System
#  2 Baseboard
#  3 Chassis
#  4 Processor
#  5 Memory Controller
#  6 Memory Module
#  7 Cache
#  8 Port Connector
#  9 System Slots
# 10 On Board Devices
# 11 OEM Strings
# 12 System Configuration Options
# 13 BIOS Language
# 14 Group Associations
# 15 System Event Log
# 16 Physical Memory Array
# 17 Memory Device
# 18 32-bit Memory Error
# 19 Memory Array Mapped Address
# 20 Memory Device Mapped Address
# 21 Built-in Pointing Device
# 22 Portable Battery
# 23 System Reset
# 24 Hardware Security
# 25 System Power Controls
# 26 Voltage Probe
# 27 Cooling Device
# 28 Temperature Probe
# 29 Electrical Current Probe
# 30 Out-of-band Remote Access31   Boot Integrity Services
# 32 System Boot
# 33 64-bit Memory Error
# 34 Management Device
# 35 Management Device Component
# 36 Management Device Threshold Data
# 37 Memory Channel
# 38 IPMI Device
# 39 Power Supply
# 40 Additional Information
# 41 Onboard Devices Extended Information
# 42 Management Controller Host Interface
