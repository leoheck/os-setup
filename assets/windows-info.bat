echo off

cls

set owner_name=
set serial_number=
set model=
set year=
set warranty_expiration=
set amex_warranty_expiration=
set processor=
set n_cpus=
set n_cores=
set memory_size=
set gpu=
set disk_size=


rem username
[Environment]::UserName
$env:username
whoami
$owner_name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
echo $owner_name.Full.split("\")[1]

rem serial number
$owner_name = mic bios get serialnumber

rem model
$model = wmic baseboard get product,version

rem processor
$preocessor = Get-WmiObject -Class Win32_Processor | Select-Object -Property Name

rem memory in GB
$memory_size = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb

rem gpu
wmic path win32_VideoController get name
$gpu = Get-WmiObject win32_VideoController

rem disk
Get-CimInstance -ClassName Win32_LogicalDisk
Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,FreeSpace
Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }}
$disk_size = gwmi win32_logicaldisk | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}


echo
echo   SYSTEM INFO SUMMARY
echo
echo                     Owner: %owner_name%
echo             Serial Number: %serial_number%
echo                     Model: %model%
echo                      Year: %year%
echo       Warranty Expiration: %warranty_expiration%
echo  Amex Warranty Expiration: %amex_warranty_expiration%
echo                 Processor: %processor%
echo                      CPUs: %n_cpus%
echo                     Cores: %n_cores%
echo                    Memory: %memory_size% GB
echo                       GPU: %gpu%
echo                 Disk Size: %disk_size% GB
echo


# Logfile
current_date=$(date +"%Y-%m-%d_%Hh%M")
output_file="${serial_number}_${current_date}_${USER}.csv"
echo "\"${owner_name}\",\"${serial_number}\",\"${model}\",\"${year}\",\"${warranty_expiration}\",\"${amex_warranty_expiration}\",\"${processor}\",\"${n_cpus}\",\"${n_cores}\",\"${memory_size}\",\"${gpu}\",\"${disk_size}\"" > ${output_file}

echo "Output file: ${output_file}"
echo