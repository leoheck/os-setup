# OSX-Setup Scripts

Here I have some scripts to assist my setup of Macbooks.

### Main user initialization
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/osx-setup/main/poaoffice-init.sh)"
```

### Scripts

After installing minimum-required stuff
```
cd ~/Documents/osx-setup

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
sh -c "$(curl -fsSL https://raw.github.com/leoheck/osx-setup/master/set-hostname.sh)" "" USERNAME
```

### Computer Info
```
# macOS on Macbooks
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/macos-info.sh)" 

# Linux on Dell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/linux-info.sh)"

# Windows on Dell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/win-info.ps1'))
```
