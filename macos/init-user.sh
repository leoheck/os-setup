#!/bin/bash

# Initialize main user

function ctrl_c() {
    if [[ -n ${sudo_alive_pid} ]]; then
        kill "${sudo_alive_pid}"
    fi
    exit 1
}

set_terminal_title()
{
    title="Init ${USER}"
    echo -n -e "\033]0;${title}\007"
}

elevate_permissions()
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
}

keep_sudo_password_alive()
{
    sudo touch /tmp/.sudo
    while :; do sudo -v; sleep 1; done &
}

install_homebrew()
{
    export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
    eval "$(brew shellenv)"

    # Fix some permissions
    if [[ "${FIX_PERMISSIONS}" != "" ]]; then
        echo "Fixing Homebrew permissions..."
        sudo chown -R ${USER} /usr/local/ &> /dev/null
        sudo chmod -R u+w /usr/local/ &> /dev/null
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

    brew update
}

install_homebrew_modules()
{
    brew install coreutils
    brew install git
    # brew install dockutil
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
    brew install --cask appcleaner    2> /dev/null
    brew install --cask google-chat   2> /dev/null
    brew install --cask google-chrome 2> /dev/null
    brew install --cask sublime-text  2> /dev/null
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
    # dscl . create /Users/poaoffice IsHidden 0
    # defaults delete /Library/Preferences/com.apple.loginwindow HiddenUsersList
    defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add

    # Disable "Other.." option on login screen, this was enable with the "Unhide" command above
    # To open the login prompt:
    # 1. Tap any arrow key to move focus to the list of accounts (this is not visible)
    # 2. Then Option+Return, to show the user and password input fields
    # sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE

    # This should be the default
    defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME 0
    defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED 0
    defaults write /Library/Preferences/com.apple.loginwindow HideAdminUsers 0
    defaults write /Library/Preferences/com.apple.loginwindow HideLocalUsers 0
    defaults write /Library/Preferences/com.apple.loginwindow showInputMenu 0

    # Custom login message
    serial_number=$(ioreg -l | grep IOPlatformSerialNumber | cut -d"\"" -f4)
    message=$(printf "This computer is property of Ambush\nSerial Number %s\npoa.office@getambush.com" ${serial_number})
    defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "${message}"

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

configure_system()
{
    # Set system theme dark
    osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

    # Set language to English
    lang=$(sudo languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
    sudo languagesetup <<< "${lang}" &> /dev/null

    # Set keyboard to en_US
    rm -rf ~/Library/Preferences/com.apple.HIToolbox.plist
    sudo defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
    sudo killall SystemUIServer

    # Enable tap to click
    sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}

configure_finder()
{
    # Show path bar on Finder
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar on Finder
    defaults write com.apple.finder ShowStatusBar -bool true
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

    # Set docker size smaller
    defaults write com.apple.dock tilesize -integer 48
    killall Dock
}

configure_terminal()
{
    # Install terminal powerline fonts
    git clone https://github.com/powerline/fonts.git "/tmp/fonts"
    cd "/tmp/fonts"
    bash -c ./install.sh
    cd - || exit
    rm -rf "/tmp/fonts"

    # Install OH-MY-ZSH
    rm -rf "${HOME}/.oh-my-zsh/"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Set zsh with SpaceShip
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

    set_terminal_title
    elevate_permissions

    keep_sudo_password_alive
    sudo_alive_pid=$!

    install_homebrew
    install_homebrew_modules
    install_homebrew_apps
    brew cleanup

    install_dockutil

    clone_os_setup_repo

    if [[ ${USER} == "poaoffice" ]]; then
        set_hostname
        configure_login_window
        set_custom_user_picture
    fi

    configure_system
    configure_finder
    configure_dock
    configure_terminal

    collect_computer_info

    kill "${sudo_alive_pid}"
}

main "$@"
