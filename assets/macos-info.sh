#!/bin/bash

# Serial Number
# Model
# Model Year
# Waranty?

# Processor
# Disk
# Memory
# Graphics card

# serial number
serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/\"//g")

# processor
processor=$(sysctl -a | grep machdep.cpu.brand_string | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# memory size
memory_size=$(system_profiler SPHardwareDataType | grep "Memory:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# Cores
cpu_cores=$(system_profiler SPHardwareDataType | grep "Cores:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# CPUS
cpus=$(sysctl -n hw.ncpu)

# GPU
gpu=$(system_profiler SPDisplaysDataType | grep -m1 "Chipset Model" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# Disk Size
disk_size=$(diskutil info /dev/disk1 | grep "Disk Size" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1)

echo
echo "Serial Number: ${serial_number}"
echo "Processor: ${processor}"
echo "Memory Size (GB): ${memory_size}"
echo "Cores: ${cores}"
echo "CPUS: ${cpus}"
echo "GPU: ${gpu}"
echo "Disk Space (GB): ${disk_size}"
echo
