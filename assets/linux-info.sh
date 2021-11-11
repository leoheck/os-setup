#!/bin/bash

# Linux (Dell)

clear

# Dependency (Debian-based)
#sudo apt install -y dmidecode &> /dev/null
#sudo apt install -y bc &> /dev/null

owner_name=$(getent passwd | grep "$USER" | cut -d":" -f5 | cut -d"," -f1)

warranty_expiration=
amex_warranty_expiration=
# amex_warranty_expiration=$(date -d "${warranty_expiration}+ 1 year" +"%Y-%m-%d")

#serial_number=$(sudo dmidecode -t 1 | grep "Serial Number" | cut -d: -f2 | sed "s/^[ \t]\+//g")
#model_number=$( sudo dmidecode -t 1 | grep "Product Name"  | cut -d: -f2 | sed "s/^[ \t]\+//g")

serial_number=$(sudo dmidecode -s system-serial-number)
if echo "$serial_number" | grep -s " " &> /dev/null; then
	serial_number="NONE"
fi

model=$(sudo dmidecode -s system-product-name)

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

disk_size=$(sudo fdisk -l /dev/nvme0n1 2>&1 | grep -m1 "Disk" | cut -d" " -f3)

gpu=$(lspci | grep -i nvidia | grep "3D controller" | cut -d: -f3 | sed "s/^[ ]\+//g")
if [[ $gpu = "" ]]; then
	gpu=$(lspci | grep -i controller | grep -i nvidia | grep -i vga | cut -d: -f3 | sed "s/^[ ]\+//g" | sort | uniq -c | sed "s/^[ ]\+//g")
fi

echo
echo " SYSTEM INFO SUMMARY"
echo
echo "                   Owner: ${owner_name}"
echo "           Serial Number: ${serial_number}"
echo "                   Model: ${model}"
# echo "                    Year: ${year}"
# echo "     Warranty Expiration: ${warranty_expiration}"
# echo "Amex Warranty Expiration: ${amex_warranty_expiration}"
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
