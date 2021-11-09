@echo off

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
$owner_name = $env:username

rem serial number
$serial_number_cmd = wmic bios get serialnumber | Format-table -HideTableHeaders

rem model
$model = wmic baseboard get product,version

rem processor
$preocessor = Get-WmiObject -Class Win32_Processor | Select-Object -Property Name

rem memory in GB
$memory_size = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb

rem gpu
$gpu = wmic path win32_VideoController get name
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

rem # Logfile
rem current_date=$(date +"%Y-%m-%d_%Hh%M")
rem output_file="${serial_number}_${current_date}_${USER}.csv"
rem echo "\"${owner_name}\",\"${serial_number}\",\"${model}\",\"${year}\",\"${warranty_expiration}\",\"${amex_warranty_expiration}\",\"${processor}\",\"${n_cpus}\",\"${n_cores}\",\"${memory_size}\",\"${gpu}\",\"${disk_size}\"" > ${output_file}

rem echo "Output file: ${output_file}"
rem echo



@Echo Off
For /F "tokens=2 Delims==" %%A In ('WMIC Bios Get SerialNumber /Value') Do (
    For /F "Delims=" %%B In ("%%A") Do (
        Call :RenamePC "%%B" 
        Call :Ask4Reboot
    )
)
pause & Exit /B
::**********************************************************************
:RenamePC
WMIC ComputerSystem where Name="%ComputerName%" call Rename Name="%~1"
Exit /B
::***********************************************************************
:Ask4Reboot
(
    echo    Set Ws = CreateObject("wscript.shell"^)
    echo    Answ = MsgBox("Did you want to reboot your computer ?"_
    echo ,VbYesNo+VbQuestion,"Did you want to reboot your computer ?"^)
    echo    If Answ = VbYes then 
    echo        Return = Ws.Run("cmd /c shutdown -r -t 60 -c ""You need to reboot in 1 minute."" -f",0,True^)
    echo    Else
    echo        wscript.Quit(1^)
    echo    End If
)>"%tmp%\%~n0.vbs"
Start "" "%tmp%\%~n0.vbs"