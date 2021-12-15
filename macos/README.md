# macOS Setup

There are some scripts to assist my setup of MacBooks.

### Main user initialization
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init.sh?foo=${RANDOM})"
```

### Scripts

After installing minimum-required stuff
```
./create-user.sh FIRSTNAME [LASTNAME] [HOSTNAME] [PASSWORD]
./set-hostname.sh [HOSTNAME]
./delete-user.sh USERNAME
```

### Extra scripts

If you don't have git installed, you can use this to update scripts easily.
```
update-scripts.sh
```

### Set a hostname
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/set-hostname.sh)" "" $USER
```
