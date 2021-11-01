# osx-setup

Some scripts to assist my OSX setup

### Install minium-required stuff
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

To update scripts without git installed use this  
```
update-scripts.sh
```
