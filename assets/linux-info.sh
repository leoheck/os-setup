#!/bin/bash

# Linux

echo "Collecting computer's info..."

# Dependencies (Debian-based)
#sudo apt install -y dmidecode &> /dev/null
#sudo apt install -y bc &> /dev/null

# Owner full name
owner_name=$(getent passwd | grep "$USER" | cut -d":" -f5 | cut -d"," -f1)

# Username
username=$USER

# Warranty
warranty_expiration=

# Extra Warranty Date (1 year)
if [[ $warranty_expiration != "" ]]; then
	extra_warranty_expiration=$(date -d "${warranty_expiration}+ 1 year" +"%Y-%m-%d")
else
	extra_warranty_expiration=
fi

# Serial Number (Service Tag)
serial_number=$(sudo dmidecode -s system-serial-number)
if echo "$serial_number" | grep -s " " &> /dev/null; then
	serial_number="NONE"
fi

# Computer Brand
brand=$(cat /sys/class/dmi/id/board_vendor | sed "s/ Inc.//g")

# Computer Model
model=$(sudo dmidecode -s system-product-name)

# Memory (GB)
memory_size=$(free --gibi | grep Mem | sed "s/[ \t]\+/ /g" | cut -d" " -f2)

# Processor details
processor=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")
n_cpus=$(echo $(cat /proc/cpuinfo | grep "processor" | tail -1 | cut -d: -f2 | sed "s/^[ ]\+//g")+1 | bc)
n_cores=$(cat /proc/cpuinfo | grep "cpu cores" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")

# Graphics
gpu=$(lspci | grep -i nvidia | grep "3D controller" | cut -d: -f3 | sed "s/^[ ]\+//g")
if [[ $gpu = "" ]]; then
	gpu=$(lspci | grep -i controller | grep -i nvidia | grep -i vga | cut -d: -f3 | sed "s/^[ ]\+//g" | sort | uniq -c | sed "s/^[ ]\+//g")
fi

# (Main) Disk Size (GB)
disk_size=$(sudo fdisk -l /dev/nvme0n1 2>&1 | grep -m1 "Disk" | cut -d" " -f3)

status=
notes=
email=

clear

echo
echo " SYSTEM INFO SUMMARY"
echo
echo "                   Owner: ${owner_name}"
echo "           Serial Number: ${serial_number}"
echo "                   Brand: ${brand}"
echo "                   Model: ${model}"
# echo "                    Year: ${year}"
# echo "     Warranty Expiration: ${warranty_expiration}"
# echo "Amex Warranty Expiration: ${extra_warranty_expiration}"
echo "               Processor: ${processor}"
echo "                    CPUs: ${n_cpus}"
echo "                   Cores: ${n_cores}"
echo "                  Memory: ${memory_size} GB"
echo "                     GPU: ${gpu}"
echo "               Disk Size: ${disk_size} GB"
echo

# Generate csv file
current_date=$(date +"%Y.%m.%d-%Hh%M")
output_file="${current_date}-${serial_number}-${USER}.csv"

read -d "" header <<-EOF
"Used By"
"Serial No"
"Brand"
"Description"
"Year"
"CPU Detail"
"CPUs"
"Cores"
"GPU Detail"
"RAM (GB)"
"Disk (GB)"
"Warrantty Expiration"
"Extra Warranty Expiration"
"Status"
"Email"
"Notes"
EOF

read -d "" data <<-EOF
"${owner_name}"
"${serial_number}"
"${brand}"
"${model}"
"${year}"
"${processor}"
"${n_cpus}"
"${n_cores}"
"${gpu}"
"${memory_size}"
"${disk_size}"
"${warranty_expiration}"
"${extra_warranty_expiration}"
"${status}"
"${email}"
"${notes}"
EOF

echo "${header}" | tr "\n" "," | sed "s/,$//g"  > ${output_file}
echo "" >> ${output_file}
echo "${data}"   | tr "\n" "," | sed "s/,$//g" >> ${output_file}
echo

echo
echo "Output file: ${output_file}"
echo
