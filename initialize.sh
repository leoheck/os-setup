#!/bin/bash

# Initialize computer with barely minium required stuff to use the command line.

# Ask for sudo password
echo
echo "Running with sudo, please type password for ${USER}"
sudo touch /tmp/initialize
echo

# Install brew
yes '' | bash -c "sudo $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install git
brew install dockutil

# Clone osx-setup scripts
cd ~
rm -rf ~/Documents/osx-setup
git clone https://github.com/leoheck/osx-setup.git ~/Documents/osx-setup
# cd $HOME/Documents/osx-setup

# Remove garbage from the dock
dockutil --remove "Calendar"
dockutil --remove "Contacts"
dockutil --remove "FaceTime"
dockutil --remove "Mail"
dockutil --remove "Maps"
dockutil --remove "Messages"
dockutil --remove "Music"
dockutil --remove "News"
dockutil --remove "Notes"
dockutil --remove "Photos"
dockutil --remove "Podcasts"
dockutil --remove "Reminders"
dockutil --remove "TV"

# Add some apps in the dock
dockutil --add /System/Applications/Utilities/Terminal.app
dockutil --add /System/Applications/TextEdit.app
dockutil --add /System/Applications/FindMy.app

# Set hostname with the serial number
yes | $HOME/Documents/osx-setup/set-hostname.sh

# Launch system settings to enable shit that cannot be enabled by script
open -a /System/Applications/System\ Preferences.app

# Enable Tap to Click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set the default picture
#sudo dscl . delete /Users/${USER} JPEGPhoto
#sudo dscl . create /Users/${USER} Picture "/Library/User Pictures/Animals/Zebra.tif"

sudo cp -f $HOME/Documents/osx-setup/poaoffice.tif "/Library/User Pictures/Animals/PoaOffice.tif"
sudo dscl . create /Users/${username} Picture "/Library/User Pictures/Animals/PoaOffice.tif"

# Set the default picture for Poa Office
# https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
sudo dscl . delete /Users/${USER} JPEGPhoto
sudo dscl . delete /Users/${USER} Picture
sudo $HOME/Documents/osx-setup/userpic.sh ${USER} $HOME/Documents/osx-setup/poaoffice.png

# (Re)Install OH-MY-ZSH (colors yay!)
rm -rf $HOME/.oh-my-zsh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update things (hopefully)
sudo AssetCacheManagerUtil reloadSettings 1> /dev/null

# Finder customizations

# Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Status Bar
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

echo
echo "DONE, Reboot to reload things!"
echo
