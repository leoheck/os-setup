# OSX-Setup Scripts

Here I have some scripts to assist my setup of Macbooks.

### Initialization (installing minium-required stuff)
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/osx-setup/master/initialize.sh)"
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
# Mac (macOS)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/macos-info.sh)" 

# Dell (Windows)
# https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/win-info.bat

# Dell (Linux)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/osx-setup/main/assets/linux-info.sh)"
```

