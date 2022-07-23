#!/bin/bash

# MacBooks and macOS info
# leoheck@gmail.com

get_computer_brand()
{
	echo "Apple"
}

get_computer_model_id()
{
	sysctl -n hw.model
}

get_computer_model_description()
{
	local serial_number="$1"

	case ${#serial_number} in
		10) local serial_last_digits=$(echo ${serial_number} | cut -c 9-) ;; # 2 characters
		11) local serial_last_digits=$(echo ${serial_number} | cut -c 9-) ;; # 3 characters
		12) local serial_last_digits=$(echo ${serial_number} | cut -c 9-) ;; # 4 characters
	esac

	local serial_last_digits=$(echo ${serial_number} | cut -c 9-)
	local model=$(curl -s https://support-sp.apple.com/sp/product\?cc\=${serial_last_digits} \
		| sed "s/.*<configCode>//g" \
		| sed "s/<\/configCode>.*//g")

	# May not work on macs with serial numbers with 10 digits, then this may work
	if echo "${model}" | grep -s -i "error" > /dev/null; then
		model=$(ioreg -l | grep "product-description" | cut -d"\"" -f4)
	fi

	echo "${model}"
}

get_computer_serial_number()
{
	ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/\"//g"
}

get_computer_models_year()
{
	local model="${1}"
	if [[ ${model} != "" ]]; then
		echo "${model}" | sed '/^[[:space:]]*$/d' | grep -o -E "[0-9]{4}"
	fi
}

get_screen_size()
{
	local model="${1}"
	echo "${model}" | grep -o "[0-9][0-9]-inch"
}

get_warranty_expiration()
{
	# Waranty for For MACs M1 (needs test, since the github script is not working)
	# curl -o - "https://support-sp.apple.com/sp/product?cc=Q6LR&lang=en_US"

	# URL=https://raw.githubusercontent.com/chilcote/warranty/master/warranty
	local url=https://raw.githubusercontent.com/leoheck/macos-warranty/master/warranty
	curl -sSL ${url} | python3 2> /dev/null | tail -1 | grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}"
}

get_extra_warranty_expiration()
{
	local warranty_expiration="${1}"
	if [[ -n ${warranty_expiration} ]]; then
		date -j -f "%Y-%m-%d" -v+1y "${warranty_expiration}" +"%Y-%m-%d"
	fi
}

#============

get_processor_id()
{
	sysctl -a | grep machdep.cpu.brand_string | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g'
}

get_nof_processors()
{
	sysctl -n hw.ncpu
}

get_nof_processor_cores()
{
	system_profiler SPHardwareDataType | grep "Cores:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1
}

get_ram_size_gb()
{
	system_profiler SPHardwareDataType | grep "Memory:" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | sed "s/ GB//g"
}

get_gpus()
{
	system_profiler SPDisplaysDataType \
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
		| sed "s/ - $/\n/g"
}

get_main_hardrive_size_gb()
{
	diskutil info /dev/disk1 | grep "Disk Size" | cut -d: -f2 | sed -Ee 's/^[[:space:]]+//g' | cut -d" " -f1
}

get_battery_cycles()
{
	system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}'
}

get_battery_health()
{
	system_profiler SPPowerDataType | grep "Condition" | awk '{print $2}'
}

#============

get_os_name()
{
	local macos_license="/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf"
	awk "/SOFTWARE LICENSE AGREEMENT FOR macOS/" "${macos_license}" \
	| awk -F 'macOS ' '{print $NF}' \
	| awk '{print substr($0, 0, length($0)-1)}'
}

get_os_version()
{
	sw_vers -productVersion
}

get_os_build()
{
	sw_vers -buildVersion
}

get_name_of_current_user()
{
	local fullname=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')
	if [[ "${fullname}" == "" ]]; then
		fullname="$(id -F)"
	fi
	echo "${fullname}"
}

#============

show_summary()
{
	clear
	echo
	echo " SYSTEM INFO SUMMARY"
	echo
	echo "                   Owner: ${current_fullname}"
	echo "                Username: ${current_username}"
	echo "           Serial Number: ${serial_number}"
	echo "                   Brand: ${brand}"
	echo "                Model ID: ${model_id}"
	echo "                   Model: ${model}"
	echo "                    Year: ${year}"
	echo "             Screen Size: ${screen_size}"
	echo "              macOS Name: ${macos_name}"
	echo "           macOS Version: ${macos_version}"
	echo "            macOS Build : ${build_version}"
	echo "     Warranty Expiration: ${warranty_expiration}"
	echo "Amex Warranty Expiration: ${extra_warranty_expiration}"
	echo "               Processor: ${processor}"
	echo "                    CPUs: ${n_cpus}"
	echo "                   Cores: ${n_cores}"
	echo "                  Memory: ${memory_size} GB"
	echo "                    GPUs: ${gpu}"
	echo "               Disk Size: ${disk_size} GB"
	echo "          Battery Health: ${battery_health}"
	echo "          Battery Cycles: ${battery_cycles}"
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
	"Processed Date"
	"Processed Time"
	"Used By"
	"Status"
	"Email"
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
	"Battery Health"
	"Battery Cycles"
	"Warrantty Expiration"
	"Extra Warranty Expiration"
	"OS Name"
	"OS Version"
	"Build Version"
	EOF

	# VALUES
	read -d "" values <<-EOF
	"${processed_date}"
	"${processed_time}"
	"${current_fullname}"
	"${computer_status}"
	"${user_email}"
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
	"${battery_health}"
	"${battery_cycles}"
	"${warranty_expiration}"
	"${extra_warranty_expiration}"
	"${macos_name}"
	"${macos_version}"
	"${build_version}"
	EOF

	if [[ "${USER}" == "poaoffice" ]]; then
		# Save the file in the iCloud drive
		output_dir_path="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Documents/Computers"
		mkdir -p "${output_dir_path}"
		csv_file="${output_dir_path}/${serial_number}.csv"
	else
		# Save the file in the Desktop
		current_date=$(date +"%Y.%m.%d-%Hh%M")
		csv_file="${HOME}/Desktop/${current_date}-${serial_number}-${USER}.csv"
	fi

	echo "${header}" | tr "\n" "," | sed "s/,$/\n/g"  > "${csv_file}"
	echo "${values}" | tr "\n" "," | sed "s/,$/\n/g" >> "${csv_file}"

	echo "CSV file: '${csv_file}'"
	echo
}


#============

main()
{
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
	battery_health=$(get_battery_health)
	battery_cycles=$(get_battery_cycles)

	# macOS Info
	macos_name=$(get_os_name)
	macos_version=$(get_os_version)
	build_version=$(get_os_build)

	# Current User Info
	current_username="${USER}"
	current_fullname=$(get_name_of_current_user)

	# Extra info of the process
	processed_date="$(date +"%Y-%m-%d")"
	processed_time="$(date +"%H:%M")"
	computer_status="Ready"
	user_email=""

	show_summary
	export_csv
}

main
