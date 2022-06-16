#!/bin/bash

# Dell and Lenovo (Linux)
# leoheck@gmail.com

# Dependencies (debian)
# sudo apt install -y dmidecode &> /dev/null
# sudo apt install -y bc &> /dev/null


check_permissions()
{
	if [ $EUID != 0 ]; then
		sudo -H "$0" "$@"
		exit $?
	fi
}

check_dependencies()
{
	if ! which dmidecode > /dev/null; then
		echo "dmidecode is missing"
		exit 1;
	fi

	if ! which bc > /dev/null; then
		echo "bc is missing"
		exit 1;
	fi
}

#============

get_computer_brand()
{
	cat /sys/class/dmi/id/board_vendor | sed "s/ Inc.//g"
}

get_computer_model_id()
{
	dmidecode -s system-product-name
}

get_computer_model_description()
{
	dmidecode -s system-product-name
}

get_computer_serial_number()
{
	# Serial Number or Service Tag
	dmidecode -s system-serial-number
}

get_computer_models_year()
{
	return
}

get_screen_size()
{
	read -d "" get_dimensions_py <<-EOF
	#!/usr/bin/env python3
	import subprocess
	# change the round factor if you like
	r = 1

	screens = [l.split()[-3:] for l in subprocess.check_output(
	    ["xrandr"]).decode("utf-8").strip().splitlines() if " connected" in l]

	for s in screens:
	    w = float(s[0].replace("mm", "")); h = float(s[2].replace("mm", "")); d = ((w**2)+(h**2))**(0.5)
	    print([round(n/25.4, r) for n in [w, h, d]])
	EOF

	size=$(python -c "${get_dimensions_py}" | sed "s/,//g" | sed "s/\[//g" | sed "s/\]//g" | cut -d" " -f3)
	size=$(echo $size | cut -d. -f1)
	echo "${size}-inch"
}

get_warranty_expiration()
{
	return
}

get_extra_warranty_expiration()
{
	local warranty_expiration="$1"
	if [[ $warranty_expiration != "" ]]; then
		date -d "${warranty_expiration}+ 1 year" +"%Y-%m-%d"
	fi
}

#============

get_processor_id()
{
	cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g"
}

get_nof_processors()
{
	echo $(cat /proc/cpuinfo | grep "processor" | tail -1 | cut -d: -f2 | sed "s/^[ ]\+//g") + 1 | bc
}

get_nof_processor_cores()
{
	cat /proc/cpuinfo | grep "cpu cores" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g"
}

get_ram_size_gb()
{
	bc <<< $(dmidecode -t 17 | sed "s/^\t//g" | grep "^Size: " | cut -d" " -f2 | tr "\n" " " | sed "s/ $//g" | tr " " "+")
}

get_gpus()
{
	local gpu=$(lspci | grep -i "[nvidia|amd]" | grep "3D controller" | cut -d: -f3 | sed "s/^[ ]\+//g")
	if [[ $gpu = "" ]]; then
		gpu=$(lspci | grep -i controller | grep -i "[nvidia|amd]" | grep -i vga | cut -d: -f3 | sed "s/^[ ]\+//g" | sort | uniq -c | sed "s/^[ ]\+//g")
	fi

	echo $gpu
}

get_main_hardrive_size_gb()
{
	parted -l 2>&1 | grep /dev/nvme0n1 | cut -d" " -f3 | sed "s/GB//g"
}

#============

get_os_name()
{
	lsb_release -si
}

get_os_version()
{
	lsb_release -sr
}

get_os_build()
{
	return
}

get_name_of_current_user()
{
	getent passwd | grep "${SUDO_USER}" | cut -d":" -f5 | cut -d"," -f1
}

#============

show_summary()
{
	clear
	echo
	echo " SYSTEM INFO SUMMARY"
	echo
	echo "                   Owner: ${owner_name}"
	echo "                Username: ${current_username}"
	echo "           Serial Number: ${serial_number}"
	echo "                   Brand: ${brand}"
	# echo "                Model ID: ${model_id}"
	echo "                   Model: ${model}"
	# echo "                    Year: ${year}"
	echo "             Screen Size: ${screen_size}"
	echo "                 OS Name: ${macos_name}"
	echo "              OS Version: ${macos_version}"
	# echo "               OS Build : ${build_version}"
	# echo "     Warranty Expiration: ${warranty_expiration}"
	# echo "Amex Warranty Expiration: ${extra_warranty_expiration}"
	echo "               Processor: ${processor}"
	echo "                    CPUs: ${n_cpus}"
	echo "                   Cores: ${n_cores}"
	echo "                  Memory: ${memory_size} GB"
	echo "                    GPUs: ${gpu}"
	echo "               Disk Size: ${disk_size} GB"
	echo
	echo
}

export_csv()
{
	# Column names have to match the ones in Airtable
	# The order of elements are not important since the colum name is used to update
	# If the field does not exist on Airtable, it can be ignored or added

	# AIRTABLE COLUMNS NAMES
	read -d "" header <<-EOF
	"Used By"
	"Serial No"
	"Brand"
	"Description"
	"Model"
	"Year"
	"Screen Size"
	"CPU Detail"
	"CPUs"
	"Cores"
	"GPU Detail"
	"RAM (GB)"
	"Disk (GB)"
	"Warrantty Expiration"
	"Extra Warranty Expiration"
	"OS Name"
	"OS Version"
	"Build Version"
	EOF

	# VALUES
	read -d "" values <<-EOF
	"${owner_name}"
	"${serial_number}"
	"${brand}"
	"${model}"
	"${model_id}"
	"${year}"
	"${screen_size}"
	"${processor}"
	"${n_cpus}"
	"${n_cores}"
	"${gpu}"
	"${memory_size}"
	"${disk_size}"
	"${warranty_expiration}"
	"${extra_warranty_expiration}"
	"${macos_name}"
	"${macos_version}"
	"${build_version}"
	EOF

	# Generate csv file
	current_date=$(date +"%Y.%m.%d-%Hh%M")
	csv_file="${current_date}-${serial_number}-${USER}.csv"

	echo "${header}" | tr "\n" "," | sed "s/,$/\n/g"  > "${csv_file}"
	echo "${values}" | tr "\n" "," | sed "s/,$/\n/g" >> "${csv_file}"

	echo "CSV file: '${csv_file}'"
	echo
}

main()
{
	check_permissions
	check_dependencies

	echo "Collecting computer's info..."

	# Computer Info
	model_id=$(get_computer_model_id)
	brand=$(get_computer_brand)
	serial_number=$(get_computer_serial_number)
	model=$(get_computer_model_description "${serial_number}")
	year=$(get_computer_models_year "${model}")
	screen_size=$(get_screen_size "${model}")

	warranty_expiration=$(get_warranty_expiration)
	extra_warranty_expiration=$(get_extra_warranty_expiration ${warranty_expiration})

	# Hardware Info
	processor=$(get_processor_id)
	n_cpus=$(get_nof_processors)
	n_cores=$(get_nof_processor_cores)
	memory_size=$(get_ram_size_gb)
	gpu=$(get_gpus)
	disk_size=$(get_main_hardrive_size_gb)

	# macOS Info
	macos_name=$(get_os_name)
	macos_version=$(get_os_version)
	build_version=$(get_os_build)

	# Current User Info
	current_username="${SUDO_USER}"
	owner_name=$(get_name_of_current_user)

	show_summary
	export_csv
}

main
