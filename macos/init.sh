#!/bin/bash

export HISTIGNORE='*sudo -S*'

# Initialize computer with barely minium required stuff to use the command line.

echo
read -s -p "(sudo) Enter password for ${USER}: " password
echo
sudo -S -k <<< "${password}" touch /tmp/init_script &> /dev/null
ret=$?
if [ ! ${ret} -eq 0 ]; then
    echo "Wrong password"
    exit 1
fi

# Fix some permissions (for already installed machines)
#echo "Fixing permissions..."
#sudo -S -k <<< "${password}" chown -R ${USER} /usr/local/ &> /dev/null
#sudo -S -k <<< "${password}" chmod -R u+w /usr/local/ &> /dev/null

# Install brew
# bash -c "sudo -S -k <<< "${password}" yes '' | $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Installing brew..."
echo | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null
ret=$?
if [ ! ${ret} -eq 0 ]; then
    echo "Something went wrong with brew install"
    exit 1
fi

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install required tools
brew update
brew install git
brew install dockutil

# Install basic usefull software
if [ ! -d "/Applications/Chat.app" ]
then
    curl -SsLo ${HOME}/Downloads/GoogleChat.dmg https://dl.google.com/chat/latest/InstallHangoutsChat.dmg
    sudo -S -k <<< "${password}" hdiutil attach ${HOME}/Downloads/GoogleChat.dmg
    sudo -S -k <<< "${password}" cp -R "/Volumes/Install Hangouts Chat/Chat.app" /Applications
    sudo -S -k <<< "${password}" hdiutil unmount "/Volumes/Install Hangouts Chat"
    rm -rf ${HOME}/Downloads/GoogleChat.dmg
fi

if [ ! -d "/Applications/Google Chrome.app" ]
then
    curl -SsLo ${HOME}/Downloads/GoogleChrome.dmg https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
    sudo -S -k <<< "${password}" hdiutil attach ${HOME}/Downloads/GoogleChrome.dmg
    sudo -S -k <<< "${password}" cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications
    sudo -S -k <<< "${password}" hdiutil unmount "/Volumes/Google Chrome"
    rm -rf ${HOME}/Downloads/GoogleChrome.dmg
fi

if [ ! -d "/Applications/AppCleaner.app" ]
then
    rm -rf ${HOME}/Downloads/AppCleaner.*
    curl -SsLo "${HOME}/Downloads/AppCleaner.zip" https://freemacsoft.net/downloads/AppCleaner_3.6.zip
    unzip -q AppCleaner.zip
    sudo -S -k <<< "${password}" mv "${HOME}/Downloads/AppCleaner.app" -f /Applications/
    rm -rf ${HOME}/Downloads/AppCleaner.*
fi

# Clone os-setup scripts
cd ~
rm -rf ${HOME}/os-setup
git clone https://github.com/leoheck/os-setup.git ${HOME}/os-setup

# Remove garbage from the dock
dockutil --remove "App Store" &> /dev/null
dockutil --remove "Calendar" &> /dev/null
dockutil --remove "Contacts" &> /dev/null
dockutil --remove "FaceTime" &> /dev/null
dockutil --remove "Keynote" &> /dev/null
dockutil --remove "Mail" &> /dev/null
dockutil --remove "Maps" &> /dev/null
dockutil --remove "Messages" &> /dev/null
dockutil --remove "Music" &> /dev/null
dockutil --remove "News" &> /dev/null
dockutil --remove "Notes" &> /dev/null
dockutil --remove "Numbers" &> /dev/null
dockutil --remove "Pages" &> /dev/null
dockutil --remove "Photos" &> /dev/null
dockutil --remove "Podcasts" &> /dev/null
dockutil --remove "Reminders" &> /dev/null
dockutil --remove "TV" &> /dev/null

# Add some apps in the dock
dockutil --add /System/Applications/Utilities/Terminal.app &> /dev/null
dockutil --add /System/Applications/TextEdit.app  &> /dev/null
dockutil --add /System/Applications/FindMy.app  &> /dev/null
dockutil --add "/Applications/Google Chrome.app"  &> /dev/null
dockutil --add "/Applications/Chat.app"  &> /dev/null
dockutil --add "/Applications/AppCleaner.app"  &> /dev/null

# Docker size
defaults write com.apple.dock tilesize -integer 48
killall Dock

# Set hostname with the serial number
sudo -S -k <<< "${password}" yes '' | ${HOME}/os-setup/macos/set-hostname.sh &> /dev/null

# Enable Tap to Click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo -S -k <<< "${password}" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo -S -k <<< "${password}" defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo -S -k <<< "${password}" defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set the default picture for Poa Office
# https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
sudo -S -k <<< "${password}" dscl . delete /Users/${USER} JPEGPhoto
sudo -S -k <<< "${password}" dscl . delete /Users/${USER} Picture
sudo -S -k <<< "${password}" dscl . create /Users/${username} Picture "/Library/User Pictures/Office/poaoffice.png"
sudo -S -k <<< "${password}" mkdir -p "/Library/User Pictures/Office/"
sudo -S -k <<< "${password}" cp -f ${HOME}/os-setup/macos/imgs/poaoffice.tif "/Library/User Pictures/Office/poaoffice.tif"
sudo -S -k <<< "${password}" ${HOME}/os-setup/macos/userpic.sh ${USER} "/Library/User Pictures/Office/poaoffice.tif"

# (Re)Install OH-MY-ZSH (colors yay!)
rm -rf ${HOME}/.oh-my-zsh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update things (hopefully)
sudo -S -k <<< "${password}" AssetCacheManagerUtil reloadSettings 2> /dev/null

# Finder > Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > Status Bar
defaults write com.apple.finder ShowStatusBar -bool true

# Powerline Fonts
git clone https://github.com/powerline/fonts.git
cd fonts
sh -c ./install.sh
cd -

# Zsh Spacehship Theme
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sed -i "" "s/robbyrussell/spaceship/g" ${HOME}/.zshrc

brew cleanup

# Disable Guest user
# Didnt work
# sudo -S -k <<< "${password}" fdesetup remove -user Guest

# Force system back to English
choice=$(sudo -S -k <<< "${password}" languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
sudo -S -k <<< "${password}" languagesetup <<< ${choice} &> /dev/null

# Force current keyboard back to English
find /Library/Preferences/com.apple.HIToolbox.plist
sudo -S -k <<< "${password}" defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
sudo -S -k <<< "${password}" killall SystemUIServer

# Force theme clolor to dark
# https://grrr.tech/posts/2020/switch-dark-mode-os/
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

# Finish by going to the scripts folder
cd ${HOME}/os-setup

# Launch system settings to enable shit that cannot be enabled by script
# echo
# echo
# echo "Turning Remote Login on requires Full Disk Access privileges"
# echo
# echo "To enable the Remote Login go to:"
# echo
# echo "    System Preferences > Security & Privacy > Privacy (tab) > Full Disk Access"
# echo "    And Enable it for Terminal app"
# open -a /System/Applications/System\ Preferences.app &
# echo
# echo
