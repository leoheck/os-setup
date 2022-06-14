
### Getting computer's info

macOS
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/macos-info.sh)"
```

Windows (using powershell)
```
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/windows-info.ps1'))
```

Linux
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/linux/linux-info.sh)"
```
