@echo off

cls

rem set owner_name=
rem set serial_number=
rem set model=
rem set year=
rem set warranty_expiration=
rem set amex_warranty_expiration=
rem set processor=
rem set n_cpus=
rem set n_cores=
rem set memory_size=
rem set gpu=
rem set disk_size=

rem username
$username = $env:username -replace "\n","-"
$owner_name = (gwmi win32_operatingsystem).RegisteredUser

rem serial number
$serial_number = (gwmi win32_bios).SerialNumber

rem model
$model = (Get-CimInstance -ClassName Win32_ComputerSystem).Model

rem processor
$preocessor = (Get-WmiObject -Class Win32_Processor).Name

$n_cpus = (gwmi -cl win32_processor).NumberOfLogicalProcessors
$n_cores = (gwmi -cl win32_processor).NumberOfCores

rem memory in GB
$memory_size = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb

rem gpu
$gpu = (Get-WmiObject win32_VideoController).Name[0]

rem disk
$disk_size = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property FreeSpace).FreeSpace /1gb -as [int]

echo
echo   SYSTEM INFO SUMMARY
echo
echo                     Owner: ${owner_name}
echo             Serial Number: ${serial_number}
echo                     Model: ${model}
echo                      Year: ${year}
echo       Warranty Expiration: ${warranty_expiration}
echo  Amex Warranty Expiration: ${amex_warranty_expiration}
echo                 Processor: ${processor}
echo                      CPUs: ${n_cpus}
echo                     Cores: ${n_cores}
echo                    Memory: ${memory_size} GB
echo                       GPU: ${gpu}
echo                 Disk Size: ${disk_size} GB
echo

rem # Logfile

$current_date = $(date +"%Y-%m-%d_%Hh%M")

$current_date = Get-Date -Format "yyyy-MM-dd_HHhmm"

$output_file = "${serial_number}_${current_date}_${username}.csv"

echo "\"${owner_name}\",\"${serial_number}\",\"${model}\",\"${year}\",\"${warranty_expiration}\",\"${amex_warranty_expiration}\",\"${processor}\",\"${n_cpus}\",\"${n_cores}\",\"${memory_size}\",\"${gpu}\",\"${disk_size}\"" > ${output_file}

echo "Output file: $(pwd)\${output_file}"
echo
