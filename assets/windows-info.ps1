
# Enable script execution with
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Powershell script

cls

# Owner full name
$dom = $env:userdomain
$usr = $env:username
$owner_name = ([adsi]"WinNT://$dom/$usr,user").fullname

# Username
$username = $env:UserName

# Serial Number (Service Tag)
$serial_number = (gwmi win32_bios).SerialNumber

# Brand
$brand = (Get-CimInstance -ClassName Win32_ComputerSystem).manufacturer

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
$current_date = Get-Date -UFormat "%Y-%m-%d_%Hh%M"
$output_file = "([Environment]::GetFolderPath("Desktop"))\${serial_number}_${current_date}_${username}.csv"
echo "`"${owner_name}`",`"${serial_number}`",`"${model}`",`"${year}`",`"${warranty_expiration}`",`"${amex_warranty_expiration}`",`"${processor}`",`"${n_cpus}`",`"${n_cores}`",`"${memory_size}`",`"${gpu}`",`"${disk_size}`"" > ${output_file}

echo "Output file: $(pwd)\${output_file}"
echo ""

# Launhch exploring to show the file
#explorer.exe $(pwd)
