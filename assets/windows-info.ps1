
# Enable script execution with
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Powershell script
# Windows users 

cls

# username
$username = $env:username -replace "\s","."
$owner_name = (gwmi win32_operatingsystem).RegisteredUser

# serial number
$serial_number = (gwmi win32_bios).SerialNumber

# model
$model = (gcim -cl Win32_ComputerSystem).Model

# processor
$processor = (gwmi -cl win32_processor).Name
$n_cpus = (gwmi -cl win32_processor).NumberOfLogicalProcessors
$n_cores = (gwmi -cl win32_processor).NumberOfCores

# memory in GB
$memory_size = (gcim Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb

# gpu
$gpu = (gwmi win32_VideoController).Name
if ( $gpu -is [array] )
{
    $gpu = (gwmi win32_VideoController).Name[0]
}


# disk
$disk_size = (gcim -cl Win32_LogicalDisk | Select-Object -Property Size).Size /1gb -as [int]

echo ""
echo "  SYSTEM INFO SUMMARY"
echo ""
echo "                    Owner: $owner_name"
echo "            Serial Number: $serial_number"
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

# Logfile
$current_date = Get-Date -UFormat "%Y-%m-%d_%Hh%M"
$output_file = "${serial_number}_${current_date}_${username}.csv"
echo "'${owner_name}','${serial_number}','${model}','${year}','${warranty_expiration}','${amex_warranty_expiration}','${processor}','${n_cpus}','${n_cores}','${memory_size}','${gpu}','${disk_size}'" > ${output_file}

echo "Output file: $(pwd)\${output_file}"
echo ""
