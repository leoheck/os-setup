#!/bin/bash

# Initialize computer with barely minium required stuff to use the command line.

# Ask for sudo password
echo
echo "Running with sudo, please type password for ${USER}"
sudo touch /tmp/unlock_sudo
echo

# Fix some permissions
sudo chown -R $(whoami) /usr/local/ &> /dev/null
sudo chmod -R u+w /usr/local/ &> /dev/null

# Install and load brew
yes '' | bash -c "sudo $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
#eval "$(/opt/homebrew/bin/brew shellenv)"

# Install required tools
brew install git
brew install dockutil


# Install basic usefull software

if [ ! -d "/Applications/Chat.app" ]
then
    curl -SsLo ${HOME}/Downloads/GoogleChat.dmg https://dl.google.com/chat/latest/InstallHangoutsChat.dmg
    sudo hdiutil attach ${HOME}/Downloads/GoogleChat.dmg
    sudo cp -R "/Volumes/Install Hangouts Chat/Chat.app" /Applications
    sudo hdiutil unmount "/Volumes/Install Hangouts Chat"
    rm -rf ${HOME}/Downloads/GoogleChat.dmg
fi

if [ ! -d "/Applications/Google Chrome.app" ]
then
    curl -SsLo ${HOME}/Downloads/GoogleChrome.dmg https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
    sudo hdiutil attach ${HOME}/Downloads/GoogleChrome.dmg
    sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications
    sudo hdiutil unmount "/Volumes/Google Chrome"
    rm -rf ${HOME}/Downloads/GoogleChrome.dmg
fi

if [ ! -d "/Applications/AppCleaner.app" ]
then
    rm -rf ${HOME}/Downloads/AppCleaner.*
    curl -SsLo ${HOME}/Downloads/AppCleaner.zip https://freemacsoft.net/downloads/AppCleaner_3.6.zip
    unzip -q AppCleaner.zip
    mv ${HOME}/Downloads/AppCleaner.app -f /Applications/
    rm -rf AppCleaner.zip
fi

# Clone osx-setup scripts
cd ~
rm -rf ${HOME}/osx-setup
git clone https://github.com/leoheck/osx-setup.git ${HOME}/osx-setup

# Remove garbage from the dock
dockutil --remove "App Store"
dockutil --remove "Calendar"
dockutil --remove "Contacts"
dockutil --remove "FaceTime"
dockutil --remove "Keynote"
dockutil --remove "Mail"
dockutil --remove "Maps"
dockutil --remove "Messages"
dockutil --remove "Music"
dockutil --remove "News"
dockutil --remove "Notes"
dockutil --remove "Numbers"
dockutil --remove "Pages"
dockutil --remove "Photos"
dockutil --remove "Podcasts"
dockutil --remove "Reminders"
dockutil --remove "TV"

# Add some apps in the dock
dockutil --add /System/Applications/Utilities/Terminal.app
dockutil --add /System/Applications/TextEdit.app
dockutil --add /System/Applications/FindMy.app
dockutil --add "/Applications/Google Chrome.app"
dockutil --add "/Applications/Chat.app"
dockutil --add /Applications/AppCleaner.app

# Docker size
defaults write com.apple.dock tilesize -integer 48
killall Dock

# Set hostname with the serial number
yes | ${HOME}/osx-setup/set-hostname.sh

# Enable Tap to Click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set the default picture
#sudo dscl . delete /Users/${USER} JPEGPhoto
#sudo dscl . create /Users/${USER} Picture "/Library/User Pictures/Animals/Zebra.tif"

# Set the default picture for Poa Office
# https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
sudo dscl . delete /Users/${USER} JPEGPhoto
sudo dscl . delete /Users/${USER} Picture
sudo mkdir -p "/Library/User Pictures/Office/"
sudo cp -f ${HOME}/osx-setup/imgs/poaoffice.tif "/Library/User Pictures/Office/PoaOffice.tif"
sudo dscl . create /Users/${username} Picture "/Library/User Pictures/Office/PoaOffice.tif"
sudo ${HOME}/osx-setup/userpic.sh ${USER} "/Library/User Pictures/Office/PoaOffice.tif"

# (Re)Install OH-MY-ZSH (colors yay!)
rm -rf ${HOME}/.oh-my-zsh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update things (hopefully)
sudo AssetCacheManagerUtil reloadSettings 2> /dev/null

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

# Launch system settings to enable shit that cannot be enabled by script
echo
echo
echo "Turning Remote Login on requires Full Disk Access privileges"
echo
echo "To enable the Remote Login go to:"
echo
echo "    System Preferences > Security & Privacy > Privacy (tab) > Full Disk Access"
echo "    And Enable it for Terminal app"
open -a /System/Applications/System\ Preferences.app &
echo
echo

# Disable Guest user
# Didnt work
# sudo fdesetup remove -user Guest

# Force system back to English
choice=$(sudo languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
sudo languagesetup <<< ${choice} &> /dev/null

# Force current keyboard back to English
find ~/Library/Preferences/ByHost/com.apple.HIToolbox.*
sudo defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
sudo killall SystemUIServer

# Force theme back to white
# https://apple.stackexchange.com/questions/391686/how-to-set-dark-mode-appearance-to-auto-in-terminal
# sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true

# Finish by going to the scripts folder
cd ${HOME}/osx-setup
