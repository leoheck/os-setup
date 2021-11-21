
# Enable script execution with
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Powershell script

echo "Colleting computer's info..." 

# Owner full name
$dom = $env:userdomain
$usr = $env:username
$owner_name = ([adsi]"WinNT://$dom/$usr,user").fullname

# Username
$username = $env:UserName

# Serial Number (Service Tag)
$serial_number = (gwmi win32_bios).SerialNumber

# Brand
$brand = (Get-CimInstance -ClassName Win32_ComputerSystem).manufacturer.replace(" Inc.","")

# Laptop Model
$model = (gcim -cl Win32_ComputerSystem).Model

# Processor Detail
$processor = (gwmi -cl win32_processor).Name
$n_cpus = (gwmi -cl win32_processor).NumberOfLogicalProcessors
$n_cores = (gwmi -cl win32_processor).NumberOfCores

# Memory (GB)
$memory_size = (gcim Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb

# GPU Details
$gpu = (gwmi win32_VideoController).Name
if ( $gpu -is [array] )
{
    $gpu = (gwmi win32_VideoController).Name[0]
}

# (Main) Disk Size (GB)
$disk_size = (gcim -cl Win32_LogicalDisk | Select-Object -Property Size).Size /1gb -as [int]

status=
notes=
email=

cls

echo ""
echo "  SYSTEM INFO SUMMARY"
echo ""
echo "                    Owner: $owner_name"
echo "            Serial Number: $serial_number"
echo "                    Brand: $brand"
echo "                    Model: $model"
# echo "                     Year: $year"
# echo "      Warranty Expiration: $warranty_expiration"
# echo " Amex Warranty Expiration: $amex_warranty_expiration"
echo "                Processor: $processor"
echo "                     CPUs: $n_cpus"
echo "                    Cores: $n_cores"
echo "                   Memory: $memory_size GB"
echo "                      GPU: $gpu"
echo "                Disk Size: $disk_size GB"
echo ""
echo ""

# Generate csv file
$current_date = Get-Date -UFormat "%Y.%m.%d-%Hh%M"
$desktop_path = ([Environment]::GetFolderPath("Desktop"))
$output_file = "${desktop_path}\${current_date}-${serial_number}-${username}.csv"

$header=@"
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
"@

$data=@"
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
"@

echo "${header}" | tr "\n" "," | sed "s/,$//g"  > ${output_file}
echo "" >> ${output_file}
echo "${data}"   | tr "\n" "," | sed "s/,$//g" >> ${output_file}
echo

echo "Output file: ${output_file}"
echo ""
