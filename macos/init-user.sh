#!/bin/bash

# Initialize main user

function ctrl_c()
{
    if [[ -n ${sudo_alive_pid} ]]; then
        kill "${sudo_alive_pid}"
    fi
    exit 1
}

ask_sudo_password()
{
    export HISTIGNORE='*sudo -S*'

    echo
    read -s -p "(sudo) Enter password for ${USER}: " password
    echo
    sudo -S <<< "${password}" touch /tmp/.init_script &> /dev/null

    ret=$?
    if [ ! ${ret} -eq 0 ]; then
        echo "Wrong password"
        exit 1
    fi

    keep_sudo_password_alive
    sudo_alive_pid=$!
}

keep_sudo_password_alive()
{
    sudo touch "/tmp/.sudo"
    while :; do sudo -v; sleep 1; done &
}

kill_background_taks()
{
    if [[ -n ${sudo_alive_pid} ]]; then
        kill "${sudo_alive_pid}"
    fi
}

install_xcode_cli_tools()
{
    if ! xcode-select -p &> /dev/null; then
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        xcode_version=$(softwareupdate -l | grep "\*.*Command Line Tools for Xcode" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
        sudo softwareupdate -i "${xcode_version}" --verbose
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    fi
}

fix_homebrew_permissions()
{
    echo "Fixing Homebrew permissions..."
    sudo chown -R $(whoami) $(brew --prefix)/*
}

install_homebrew()
{
    if [[ -d "/opt/homebrew/bin" ]]; then
        fix_homebrew_permissions
    else
        export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
        eval "$(brew shellenv)"

        if ! which brew 2>/dev/null; then
            rm -fr $(brew --repo homebrew/core)
            brew tap homebrew/core
        fi

        echo "Installing Homebrew..."
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
    fi

    brew update
}

install_homebrew_modules()
{
    brew install coreutils
    brew install git
    brew install jq
}

install_dockutil()
{
    latest_dockerutil_url=$(curl --silent "https://api.github.com/repos/kcrawford/dockutil/releases/latest" | jq -r '.assets[].browser_download_url' | grep pkg)
    curl -sL ${latest_dockerutil_url} -o "/tmp/dockutil.pkg"
    sudo installer -pkg "/tmp/dockutil.pkg" -target /
    rm -f "/tmp/dockutil.pkg"
}

install_homebrew_apps()
{
    brew install --cask google-chat
    brew install --cask google-chrome
    brew install --cask sublime-text
}

set_hostname()
{
    # set with the hostname
    yes '' | sudo "${HOME}/Donwloads/os-setup/macos/set-hostname.sh"
}

configure_login_window()
{
    # https://developer.apple.com/documentation/devicemanagement/loginwindow

    # Disable guest user
    sudo sysadminctl -guestAccount off

    # Hide poaoffice user from login screen
    # sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add ${USER}

    # Unhide poaoffice if it was hidden
    sudo dscl . create /Users/poaoffice IsHidden 0
    sudo defaults delete /Library/Preferences/com.apple.loginwindow HiddenUsersList
    # Override with a clean array
    # sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add

    # Disable "Other.." option on login screen, this was enable with the "Unhide" command above
    # To open the login prompt:
    # 1. Tap any arrow key to move focus to the list of accounts (this is not visible)
    # 2. Then Option+Return, to show the user and password input fields
    # sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE

    # This should be the default
    sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool false
    sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool false
    sudo defaults write /Library/Preferences/com.apple.loginwindow HideAdminUsers -bool false
    sudo defaults write /Library/Preferences/com.apple.loginwindow HideLocalUsers -bool false
    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool false

    # Custom login message
    serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d"\"" -f4)
    message=$(printf "This computer is property of Ambush\nSerial Number %s\npoa.office@getambush.com" ${serial_number})
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "${message}"
}

clone_os_setup_repo()
{
    rm -rf "${HOME}/Donwloads/os-setup"
    git clone https://github.com/leoheck/os-setup.git "${HOME}/Donwloads/os-setup"
}

set_custom_user_picture()
{
    # Set the default picture for Poa Office
    # https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
    sudo dscl . delete "/Users/${USER}" JPEGPhoto
    sudo dscl . delete "/Users/${USER}" Picture
    sudo mkdir -p "/Library/User Pictures/Office/"
    sudo cp -f "${HOME}/Donwloads/os-setup/macos/imgs/poaoffice.tif" "/Library/User Pictures/Office/poaoffice.tif"
    sudo dscl . create "/Users/${USER}" Picture "/Library/User Pictures/Office/poaoffice.png"
    sudo "${HOME}/Donwloads/os-setup/macos/set-user-picture.sh" ${USER} "/Library/User Pictures/Office/poaoffice.tif"
    sudo AssetCacheManagerUtil reloadSettings 2> /dev/null
}

system_wide_settings()
{
    # Set system theme dark
    osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

    # Reset language to English
    lang=$(sudo languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
    sudo languagesetup <<< "${lang}" &> /dev/null

    # reset keyboard to en_US
    rm -rf ~/Library/Preferences/com.apple.HIToolbox.plist
    sudo defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
    sudo killall SystemUIServer

    # Enable tap to click
    sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # reset password policies, (if they were changed by MDMs)
    sudo pwpolicy -clearaccountpolicies

    # Showing all filename extensions in Finder by default
    sudo defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Check for software updates daily, not just once per week
    sudo defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Avoiding the creation of .DS_Store files on network volumes
    sudo defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
}

configure_finder()
{
    # Show some hidden directories by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Always show the list view
    defaults write com.apple.Finder FXPreferredViewStyle Nlsv

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true

    # Disabling the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Force reload settings
    killall Finder
}

configure_dock()
{
    # Remove garbage from dock
    dockutil --remove "App Store" 2> /dev/null
    dockutil --remove "Calendar"  2> /dev/null
    dockutil --remove "Contacts"  2> /dev/null
    dockutil --remove "FaceTime"  2> /dev/null
    dockutil --remove "Keynote"   2> /dev/null
    dockutil --remove "Mail"      2> /dev/null
    dockutil --remove "Maps"      2> /dev/null
    dockutil --remove "Messages"  2> /dev/null
    dockutil --remove "Music"     2> /dev/null
    dockutil --remove "News"      2> /dev/null
    dockutil --remove "Notes"     2> /dev/null
    dockutil --remove "Numbers"   2> /dev/null
    dockutil --remove "Pages"     2> /dev/null
    dockutil --remove "Photos"    2> /dev/null
    dockutil --remove "Podcasts"  2> /dev/null
    dockutil --remove "Reminders" 2> /dev/null
    dockutil --remove "TextEdit"  2> /dev/null
    dockutil --remove "TV"        2> /dev/null

    # Add some apps in dock
    dockutil --add "/System/Applications/Utilities/Terminal.app" 2> /dev/null
    dockutil --add "/System/Applications/FindMy.app" 2> /dev/null
    dockutil --add "/Applications/Google Chrome.app" 2> /dev/null
    dockutil --add "/Applications/Chat.app" 2> /dev/null
    dockutil --add "/Applications/Sublime Text.app" 2> /dev/null

    # Set smaller dock size
    defaults write com.apple.dock tilesize -integer 48
    killall Dock
}

update_zsh_permissions()
{
    zsh_path="/usr/local/share/zsh"
    sudo chown -R $(whoami) "${zsh_path}"
    sudo chown -R $(whoami) "${zsh_path}"/site-functions
    chmod u+w "${zsh_path}"
    chmod u+w "${zsh_path}"/site-functions
}

configure_terminal()
{
    # Install terminal powerline fonts
    git clone https://github.com/powerline/fonts.git "/tmp/fonts"
    cd "/tmp/fonts"
    bash -c ./install.sh
    cd - || exit
    rm -rf "/tmp/fonts"

    update_zsh_permissions

    # Install OH-MY-ZSH
    rm -rf "${HOME}/.oh-my-zsh/"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Set Spaceship theme
    ZSH_CUSTOM_THEMES="${HOME}/.oh-my-zsh/custom/themes/"
    mkdir -p ${ZSH_CUSTOM_THEMES}
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${ZSH_CUSTOM_THEMES}/spaceship-prompt" --depth=1
    ln -s "${ZSH_CUSTOM_THEMES}/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM_THEMES}/spaceship.zsh-theme"
    sed -i "" "s/robbyrussell/spaceship/g" ${HOME}/.zshrc
}

collect_computer_info()
{
    # This saves the info in the iCloud folder if the user is poaoffice
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/leoheck/os-setup/main/macos/macos-info.sh)"
}

main()
{
    trap ctrl_c INT

    ask_sudo_password

    install_xcode_cli_tools

    install_homebrew
    install_homebrew_modules
    install_homebrew_apps

    install_dockutil

    clone_os_setup_repo

    system_wide_settings

    if [[ "${USER}" == "poaoffice" ]]; then
        set_hostname
        configure_login_window
        set_custom_user_picture
    fi

    configure_finder
    configure_dock
    configure_terminal

    collect_computer_info

    kill_background_taks
}

main "$@"
