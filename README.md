# osx-setup

Some scripts to assist my OSX setup

## Install minium-required stuff
```
sh -c "$(curl -fsSL https://raw.github.com/leoheck/osx-setup/master/initialize.sh)"
```

## Extra scripts

After installing minimum-required stuff
```
cd ~/Documents/osx-setup

./create-new-user.sh FIRSTNAME [LASTNAME] [HOSTNAME] [PASSWORD]
./delete-user-account.sh USERNAME
./set-hostname.sh [HOSTNAME]
```
