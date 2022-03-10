# Windows Setup

### Set the Hostname
```powershell
# using the Serial Number
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/set-hostname.ps1'))
```

```powershell
# using the Username
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/set-hostname.ps1')) $env:username
```
