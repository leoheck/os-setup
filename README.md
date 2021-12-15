# OSX-Setup Scripts

Here I have some scripts to assist my setup of Macbooks.

### Main user initialization
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/init.sh)"
```

### Scripts

After installing minimum-required stuff
```
cd ~/Documents/os-setup

./create-user.sh FIRSTNAME [LASTNAME] [HOSTNAME] [PASSWORD]
./set-hostname.sh [HOSTNAME]

./delete-user.sh USERNAME
```

### Extra scripts

If you don't have git installed, you can use this to update scripts easily.
```
update-scripts.sh
```

### Change the hostname easily
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/set-hostname.sh)" "" USERNAME
```

### Computer Info

On macOS/Macbooks
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/assets/macos-info.sh)" 
```

On Windows
```
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/os-setup/main/assets/windows-info.ps1'))
```

On Linux
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/assets/linux-info.sh)"
```
