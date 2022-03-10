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
# memory_size=$(free --gibi | grep Mem | sed "s/[ \t]\+/ /g" | cut -d" " -f2)
memory_size=$(bc <<< $(sudo dmidecode -t 17 | sed "s/^\t//g" | grep "^Size: " | cut -d" " -f2 | tr "\n" " " | sed "s/ $//g" | tr " " "+"))

# Processor details
processor=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")
n_cpus=$(echo $(cat /proc/cpuinfo | grep "processor" | tail -1 | cut -d: -f2 | sed "s/^[ ]\+//g")+1 | bc)
n_cores=$(cat /proc/cpuinfo | grep "cpu cores" | uniq | cut -d: -f2 | sed "s/^[ ]\+//g")

# (Main) Disk Size (GB)
# disk_size=$(sudo fdisk -l /dev/nvme0n1 2>&1 | grep -m1 "Disk" | cut -d" " -f3)
disk_size=$(sudo parted -l 2>&1 | grep /dev/nvme0n1 | cut -d" " -f3 | sed "s/GB//g")

# Graphics
gpu=$(lspci | grep -i nvidia | grep "3D controller" | cut -d: -f3 | sed "s/^[ ]\+//g")
if [[ $gpu = "" ]]; then
	gpu=$(lspci | grep -i controller | grep -i nvidia | grep -i vga | cut -d: -f3 | sed "s/^[ ]\+//g" | sort | uniq -c | sed "s/^[ ]\+//g")
fi

status=
notes=
email=

clear

echo
echo " SYSTEM INFO SUMMARY"
echo
echo "          Owner: ${owner_name}"
echo "  Serial Number: ${serial_number}"
echo "          Brand: ${brand}"
echo "          Model: ${model}"
echo "      Processor: ${processor}"
echo "           CPUs: ${n_cpus}"
echo "          Cores: ${n_cores}"
echo "         Memory: ${memory_size} GB"
echo "      Disk Size: ${disk_size} GB"
echo "            GPU: ${gpu}"
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

# Create csv
# echo "${header}" | tr "\n" "," | sed "s/,$//g"  > ${output_file}
# echo "" >> ${output_file}
# echo "${data}"   | tr "\n" "," | sed "s/,$//g" >> ${output_file}

# echo "Output file: ${output_file}"
# echo


#	=====================



LHECK_API="keyfeA4QBsaivkbBa"

API_KEY="${LHECK_API}"
AIRTABLE_BASE="appBiYFQh1XsIJyDo"

people_table="People"
computers_table="Computers"

computers_json_path=airtable-computers.json

donwload_table(){
	base="$1"
	url="https://api.airtable.com/v0/${AIRTABLE_BASE}/${base}?view=Grid"
	# echo "URL = ${url}"
	data_json=$(curl -SsL "${url}" -H "Authorization: Bearer ${API_KEY}")
	echo "${data_json}" | jq .
}

update_entry() {
	echo "Updating entry..."
	base="$1"
	id="$2"
	data="$3"
	url="https://api.airtable.com/v0/${AIRTABLE_BASE}/${base}/${id}"
	echo "URL = ${url}"
	echo "DATA = "
	echo "${data}" | jq --color-output .
	response=$(curl -SsL -X PATCH "${url}" \
		-H "Authorization: Bearer ${API_KEY}" \
		-H "Content-Type: application/json" \
		--data "${data}" \
	)
	ret=$?
	echo "RESPONSE = "
	echo ${response} | jq --color-output .
	echo -e "Status code = $ret"
}

create_entry() {
	echo "Creating entry..."
	base="$1"
	data="$2"
	url="https://api.airtable.com/v0/${AIRTABLE_BASE}/${base}/"
	echo "URL = ${url}"
	echo "DATA = "
	echo "${data}" | jq --color-output .
	response=$(curl -SsL -X POST "${url}" \
		-H "Authorization: Bearer ${API_KEY}" \
		-H "Content-Type: application/json" \
		--data "${data}" \
	)
	ret=$?
	echo "RESPONSE = "
	echo ${response} | jq --color-output .
	echo -e "Status code = $ret"
}

get_entry_id_from_serial_number() {
	serial_number="$1"
	entry_id=$(jq -r ".records[] | select(.fields.\"Serial No\"==\"${serial_number}\").id" ${computers_json_path})
	echo "${entry_id}"
}

donwload_table "${computers_table}" > "${computers_json_path}"

entry_id=$(get_entry_id_from_serial_number "${serial_number}")

if [[ ${entry_id} == "" ]]; then

	# "Year": ${year},
	# "Warrantty Expiration": "${warranty_expiration}",
	# "Extra Warranty Expiration": "${warranty_expiration}",

	# Send only fields that need to be updated
	read -r -d '' data_json <<-EOM
	{
	  "fields": {
		"Serial No": "${serial_number}",
		"Brand": "${brand}",
		"Description": "${model}",
		"CPU Detail": "${processor}",
		"CPUs": ${n_cpus},
		"Cores": ${n_cores},
		"RAM (GB)": ${memory_size},
		"Disk (GB)": ${disk_size},
		"GPU Detail": "${gpu}",
		"Status": "Ready",
		"Email": []
	  }
	}
	EOM

	create_entry "${computers_table}" "${data_json}"

else

	# "Status": "Ready",
	# "Warrantty Expiration": "${warranty_expiration}",
	# "Extra Warranty Expiration": "${warranty_expiration}",
	# "Email": [],
	# "Name (from Emails)": [],
	# "Division (from Email)": []
	# "Year": ${year},

	# Send only fields that need to be updated
	read -r -d '' data_json <<-EOM
	{
	  "fields": {
		"Serial No": "${serial_number}",
		"Brand": "${brand}",
		"Description": "${model}",
		"CPU Detail": "${processor}",
		"CPUs": ${n_cpus},
		"Cores": ${n_cores},
		"RAM (GB)": ${memory_size},
		"Disk (GB)": ${disk_size},
		"GPU Detail": "${gpu}"
	  }
	}
	EOM

	update_entry "${computers_table}" "${entry_id}" "${data_json}"

fi
