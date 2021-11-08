#!/bin/bash

# MAC and macOS info

clear

owner_name=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')

warranty_expiration=$(curl -sSL https://raw.githubusercontent.com/chilcote/warranty/master/warranty | python3 - | tail -1 | cut -d, -f4 | sed -e "s/\r//g")
amex_warranty_expiration=$(date -j -f "%Y-%m-%d" -v+1y "${warranty_expiration}" +"%Y-%m-%d")

# serial number
serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/\"//g")

# model=$(/usr/libexec/PlistBuddy -c "print :'CPU Names':$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 9-)-en-US_US" ~/Library/Preferences/com.apple.SystemProfiler.plist)
# model=$(defaults read "$HOME/Library/Preferences/com.apple.SystemProfiler.plist" 'CPU Names' | grep en-US | cut -d= -f2 | sed "s/\"//g" | sed "s/;//g" | sed "s/[ ]\+//g" | sed "s/^ //g")
#model=$(system_profiler SPHardwareDataType | grep "Model Name" | cut -d: -f2 | sed "s/^ //g")

serial_last_4digits=$(echo ${serial_number} | cut -c 9-)
model=$(curl -s https://support-sp.apple.com/sp/product\?cc\=${serial_last_4digits} | sed "s/.*<configCode>//g" | sed "s/<\/configCode>.*//g")

# year
year=$(echo $model | grep -E -o '[0-9]{4}')

# processor
processor=$(sysctl -a | grep machdep.cpu.brand_string | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# CPUS
n_cpus=$(sysctl -n hw.ncpu)

# Cores
n_cores=$(system_profiler SPHardwareDataType | grep "Cores:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# memory size
memory_size=$(system_profiler SPHardwareDataType | grep "Memory:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/ GB//g")

# GPU
gpu=$(system_profiler SPDisplaysDataType | grep -m1 "Chipset Model" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# Disk Size
disk_size=$(diskutil info /dev/disk1 | grep "Disk Size" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1)

echo
echo " SYSTEM INFO SUMMARY"
echo
echo "                   Owner: ${owner_name}"
echo "           Serial Number: ${serial_number}"
echo "                   Model: ${model}"
echo "                    Year: ${year}"
echo "     Warranty Expiration: ${warranty_expiration}"
echo "Amex Warranty Expiration: ${amex_warranty_expiration}"
echo "               Processor: ${processor}"
echo "                    CPUs: ${n_cpus}"
echo "                   Cores: ${n_cores}"
echo "                  Memory: ${memory_size} GB"
echo "                     GPU: ${gpu}"
echo "               Disk Size: ${disk_size} GB"
echo

# Logfile
current_date=$(date +"%Y-%m-%d_%Hh%M")
output_file="${serial_number}_${current_date}_${USER}.csv"
echo "\"${owner_name}\",\"${serial_number}\",\"${model}\",\"${year}\",\"${warranty_expiration}\",\"${amex_warranty_expiration}\",\"${processor}\",\"${n_cpus}\",\"${n_cores}\",\"${memory_size}\",\"${gpu}\",\"${disk_size}\"" > ${output_file}

echo "Output file: ${output_file}"
echo
