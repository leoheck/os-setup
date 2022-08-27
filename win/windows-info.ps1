
# Enable script execution with
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Powershell script

echo "Collecting computer's info..."

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

cls

echo ""
echo "  SYSTEM INFO SUMMARY"
echo ""
echo "                    Owner: ${owner_name}"
echo "            Serial Number: ${serial_number}"
echo "                    Brand: ${brand}"
echo "                    Model: ${model}"
echo "                Processor: ${processor}"
echo "                     CPUs: ${n_cpus}"
echo "                    Cores: ${n_cores}"
echo "                   Memory: ${memory_size} GB"
echo "                      GPU: ${gpu}"
echo "                Disk Size: ${disk_size} GB"
echo ""
echo ""

# Generate csv file
$current_date = Get-Date -UFormat "%Y.%m.%d-%Hh%M"
$desktop_path = ([Environment]::GetFolderPath("Desktop"))
$output_file = "${desktop_path}\${current_date}-${serial_number}-${username}.csv"


$registered_date = Get-Date -UFormat "%Y-%m-%d"
$computer_status = "Ready"
$user_email = "-"

$header=@"
"Registered Date"
"Used By"
"Status"
"Email"
"Serial No"
"Brand"
"Description"
"CPU Detail"
"CPUs"
"Cores"
"GPU Detail"
"RAM (GB)"
"Disk (GB)"
"@

$data=@"
"${registered_date}"
"${owner_name}"
"${computer_status}"
"${user_email}"
"${serial_number}"
"${brand}"
"${model}"
"${processor}"
"${n_cpus}"
"${n_cores}"
"${gpu}"
"${memory_size}"
"${disk_size}"
"@

# Set export encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

echo ([regex]::Replace($header, "\n", ",", "Singleline"))  > ${output_file}
echo ([regex]::Replace(  $data, "\n", ",", "Singleline")) >> ${output_file}
echo ""

echo "Output file: ${output_file}"
echo ""
