#!/bin/bash

export HISTIGNORE='*sudo -S*'

# Initialize computer with barely minium required stuff to use the command line.

echo
read -s -p "(sudo) Enter password for ${USER}: " password
echo
echo "Installing brew..."
sudo -S <<< "${password}" touch /tmp/init_script &> /dev/null

ret=$?
if [ ! ${ret} -eq 0 ]; then
    echo "Wrong password"
    exit 1
fi

# Fix some permissions
if [[ "${FIX_PERMISSIONS}" != "" ]]; then
    echo "Fixing permissions..."
    sudo chown -R ${USER} /usr/local/ &> /dev/null
    sudo chmod -R u+w /usr/local/ &> /dev/null
fi

# Install brew
# echo "Installing brew..."
yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ret=$?
if [ ! ${ret} -eq 0 ]; then
    echo "Something went wrong with brew install"
    exit 1
fi

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update

# Install required tools
brew install git
brew install dockutil

# Install basic usefull software
brew install --cask google-chat 2> /dev/null
brew install --cask sublime-text 2> /dev/null
brew install --cask google-chrome 2> /dev/null
brew install --cask appcleaner 2> /dev/null

# Clone os-setup scripts
cd ~
rm -rf ${HOME}/os-setup
git clone https://github.com/leoheck/os-setup.git ${HOME}/os-setup

# Remove garbage from the dock
dockutil --remove "App Store" 2> /dev/null
dockutil --remove "Calendar" 2> /dev/null
dockutil --remove "Contacts" 2> /dev/null
dockutil --remove "FaceTime" 2> /dev/null
dockutil --remove "Keynote" 2> /dev/null
dockutil --remove "Mail" 2> /dev/null
dockutil --remove "Maps" 2> /dev/null
dockutil --remove "Messages" 2> /dev/null
dockutil --remove "Music" 2> /dev/null
dockutil --remove "News" 2> /dev/null
dockutil --remove "Notes" 2> /dev/null
dockutil --remove "Numbers" 2> /dev/null
dockutil --remove "Pages" 2> /dev/null
dockutil --remove "Photos" 2> /dev/null
dockutil --remove "Podcasts" 2> /dev/null
dockutil --remove "Reminders" 2> /dev/null
dockutil --remove "TV" 2> /dev/null
dockutil --remove "TextEdit" 2> /dev/null

# Add some apps in the dock
dockutil --add /System/Applications/Utilities/Terminal.app 2> /dev/null
dockutil --add /System/Applications/FindMy.app  2> /dev/null
dockutil --add "/Applications/Google Chrome.app"  2> /dev/null
dockutil --add "/Applications/Chat.app"  2> /dev/null
dockutil --add "/Applications/AppCleaner.app"  2> /dev/null
dockutil --add "/Applications/Sublime Text.app"  2> /dev/null

# Docker size
defaults write com.apple.dock tilesize -integer 48
killall Dock

# Set hostname with the serial number
sudo yes '' | ${HOME}/os-setup/macos/set-hostname.sh &> /dev/null

# Enable Tap to Click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set the default picture for Poa Office
# https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
sudo dscl . delete /Users/${USER} JPEGPhoto
sudo dscl . delete /Users/${USER} Picture
sudo dscl . create /Users/${username} Picture "/Library/User Pictures/Office/poaoffice.png"
sudo mkdir -p "/Library/User Pictures/Office/"
sudo cp -f ${HOME}/os-setup/macos/imgs/poaoffice.tif "/Library/User Pictures/Office/poaoffice.tif"
sudo ${HOME}/os-setup/macos/userpic.sh ${USER} "/Library/User Pictures/Office/poaoffice.tif"

# (Re)Install OH-MY-ZSH (colors yay!)
rm -rf ${HOME}/.oh-my-zsh/
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update things (hopefully)
sudo AssetCacheManagerUtil reloadSettings 2> /dev/null

# Finder > Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > Status Bar
defaults write com.apple.finder ShowStatusBar -bool true

# Powerline Fonts
git clone https://github.com/powerline/fonts.git
cd fonts
bash -c ./install.sh
cd -
rm -rf fonts

# Zsh Spacehship Theme
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sed -i "" "s/robbyrussell/spaceship/g" ${HOME}/.zshrc

brew cleanup

# Disable Guest user
# Didnt work
# sudo fdesetup remove -user Guest

# Force system back to English
choice=$(sudo languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
sudo languagesetup <<< ${choice} &> /dev/null

# Force current keyboard back to English
find /Library/Preferences/com.apple.HIToolbox.plist
sudo defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
sudo killall SystemUIServer

# Force theme clolor to dark
# https://grrr.tech/posts/2020/switch-dark-mode-os/
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

# Finish by going to the scripts folder
cd ${HOME}/os-setup

# Refresh database with computers info
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/assets/macos-info.sh)"