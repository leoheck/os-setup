
### Collecting computer's info

macOS/Macbooks
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/assets/macos-info.sh)"
```

Windows (using powershell)
```
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/macos/assets/windows-info.ps1'))
```

Linux
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/assets/linux-info.sh)"
```
