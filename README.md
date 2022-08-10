
### Getting computer's info

macOS
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/macos-info.sh)"
```

Windows (using powershell)
```powershell
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/win/windows-info.ps1'))
```

Linux
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/linux/linux-info.sh)"
```
