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

./create-new-user.sh FIRSTNAME [LASTNAME] [HOSTNAME] [PASSWORD]
./set-hostname.sh [HOSTNAME]

./delete-user-account.sh USERNAME
```

### Extra scripts

If you don't have git installed, you can use this to update scripts easily.
```
update-scripts.sh
```

### Change the hostname easily
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/osx-setup/master/initialize.sh) USERNAME"
```
