#!/bin/bash

# Initialize computer with barely minium required stuff to use the command line.

# Install brew
/bin/bash -c "sudo $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Github
brew install git

# Install OH-MY-ZSH (colors)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Spaceship theme
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sed -i "" "s/robbyrussell/spaceship/g" ~/.zshrc

# Clone osx-setup scripts
rm -rf ~/Documents/osx-setup
git clone https://github.com/leoheck/osx-setup.git ~/Documents/osx-setup

# Launch system settings to enable shit that cannot be enabled by script
open -a /System/Applications/System\ Preferences.app
