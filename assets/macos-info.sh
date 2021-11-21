#!/bin/bash

# MAC and macOS info

clear

# Ownser fullname
owner_name=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')
if [[ $owner_name == "" ]]; then
	owner_name=$(id -F)
fi

brand=Apple

# Serial Number
serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/\"//g")

# Computer Model
# Does not work on macs with serial numbers with 10 digits
serial_last_digits=$(echo ${serial_number} | cut -c 9-)
model=$(curl -s https://support-sp.apple.com/sp/product\?cc\=${serial_last_digits} | sed "s/.*<configCode>//g" | sed "s/<\/configCode>.*//g")
if echo "${model}" | grep -s -i "error" > /dev/null; then
	model=
fi

# Computer model
if [[ ${model} != "" ]]; then
	year=$(echo "${model}" | sed '/^[[:space:]]*$/d' | grep -o -E "[0-9]{4}")
fi

warranty_expiration=$(curl -sSL https://raw.githubusercontent.com/chilcote/warranty/master/warranty | python3 2> /dev/null | tail -1 | grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}")

if [[ ${warranty_expiration} != "" ]]; then
	amex_warranty_expiration=$(date -j -f "%Y-%m-%d" -v+1y "${warranty_expiration}" +"%Y-%m-%d")
fi

# Processor details
processor=$(sysctl -a | grep machdep.cpu.brand_string | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g')

# cpus
n_cpus=$(sysctl -n hw.ncpu)

# cores
n_cores=$(system_profiler SPHardwareDataType | grep "Cores:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1)

# Memory size (GB)
memory_size=$(system_profiler SPHardwareDataType | grep "Memory:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/ GB//g")

# GPU(s) Details
gpu=$(system_profiler SPDisplaysDataType \
	| grep "Chipset Model" \
	| cut -d: -f2 \
	| sed '/^[[:space:]]*$/d' \
	| sed -Ee 's/^[[:space:]]+//g' \
	| sort \
	| uniq -c \
	| sed -Ee 's/^[[:space:]]+//g' \
	| sed "s/\([1-9]\) /\1x /g" \
	| sed "s/1x //g" \
	| tr "\n" "|" \
	| sed "s/|/ - /g" \
	| sed "s/ - $/\n/g" \
)

# (Main) Disk Size (GB)
disk_size=$(diskutil info /dev/disk1 | grep "Disk Size" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1)

echo
echo " SYSTEM INFO SUMMARY"
echo
echo "                   Owner: ${owner_name}"
echo "           Serial Number: ${serial_number}"
echo "                   Brand: ${brand}"
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

# Generate csv file
current_date=$(date +"%Y-%m-%d_%Hh%M")
output_file="${HOME}/Desktop/${serial_number}_${current_date}_${USER}.csv"
echo "\"${owner_name}\",\"${serial_number}\",\"${model}\",\"${year}\",\"${warranty_expiration}\",\"${amex_warranty_expiration}\",\"${processor}\",\"${n_cpus}\",\"${n_cores}\",\"${memory_size}\",\"${gpu}\",\"${disk_size}\"" > ${output_file}

echo "Output file: ${output_file}"
echo
