# Windows Setup

### Set the Hostname
```powershell
# using the Serial Number
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/set-hostname.sh
```

```powershell
# using the Username
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/set-hostname.sh
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" $USER
```
