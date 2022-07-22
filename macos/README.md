# macOS Setup

These are some scripts to assist my setup of MacBooks

### Init user
```
sh -c "$(curl -H 'Cache-Control: no-cache' -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init-user.sh)"
```

### Set the Hostname

With the Serial Number
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" 
```

With the Username
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" ${USER}
```
