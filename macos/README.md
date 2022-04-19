# macOS Setup

There are some scripts to assist my setup of MacBooks.

### Main User Initialization
```
sh -c "$(curl -H 'Cache-Control: no-cache' -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init-user.sh)"
```

### Scripts

After installing minimum-required stuff
```
./create-user.sh FIRSTNAME [LASTNAME] [HOSTNAME] [PASSWORD]
./set-hostname.sh [HOSTNAME]
./delete-user.sh USERNAME
```

### Extra Scripts

If you don't have git installed, you can use this to update scripts easily.
```
update-scripts.sh
```

### Set the Hostname
```
# with the Serial Number
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" 
```

```
# with the current Username
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" ${USER}
```
