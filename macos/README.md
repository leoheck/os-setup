# macOS Setup

These are some scripts to assist my setup of MacBooks

### Init user

Normal install
```bash
sh -c "$(curl -H 'Cache-Control: no-cache' \
	-fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init-user.sh)"
```

With hidden admin user
```bash
sh -c "$(curl -H 'Cache-Control: no-cache' \
	-fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init-user-hiddden.sh)"
```

Light version without brew
```bash
sh -c "$(curl -H 'Cache-Control: no-cache' \
	-fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/init-user-light.sh)"
```


### Set the Hostname

With the Serial Number
```bash
sh -c "$(curl \
	-fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" 
```

With the Username
```bash
sh -c "$(curl \
	-fsSL https://raw.github.com/leoheck/os-setup/master/macos/set-hostname.sh)" "" ${USER}
```


### Upgrade macOS with an USB Drive

> Documentation https://support.apple.com/en-us/HT201372

List macOS versions
```bash
softwareupdate --list-full-installers
```

Donwload an specific macOS
```bash
softwareupdate -d --fetch-full-installer --full-installer-version 12.5
```

Format a USB to a FAT32 to be able for mac to see it
> The right format should be MacOS Extended (Journaled)
```
diskutil eraseDisk JHFS+ MyDisk /dev/disk2
```

Flash the Bootable macOS in an USB Drive (> 16 GB)
```
sudo /Applications/Install\ macOS\ Monterey.app/Contents/Resources/createinstallmedia --volume /Volumes/MyDisk
```

### Boot in Recovery

On Intel silicon

- `Command-R`: Start up from the built-in macOS Recovery System.
- `Option-Command-R`: Start up from macOS Recovery over the internet.
- `Option-Shift-Command-R`: Start up from macOS Recovery over the internet.

On apple silicon

- Hold the Power Button

### Upgrade macOS with an USB Drive

```bash
sh -c "$(curl -H 'Cache-Control: no-cache' -fsSL shorturl.at/begx1)"
```

### Show Hidden Users at login window

`Option+Return`
