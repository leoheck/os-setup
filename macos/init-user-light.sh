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

kill_background_tasks()
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

set_hostname()
{
    # set with the hostname
    yes '' | sudo "${HOME}/Downloads/os-setup/macos/set-hostname.sh"
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
    rm -rf "${HOME}/Downloads/os-setup"
    git clone https://github.com/leoheck/os-setup.git "${HOME}/Downloads/os-setup"
}

set_custom_user_picture()
{
    # Set the default picture for Poa Office
    # https://apple.stackexchange.com/questions/117530/setting-account-picture-jpegphoto-with-dscl-in-terminal
    sudo dscl . delete "/Users/${USER}" JPEGPhoto
    sudo dscl . delete "/Users/${USER}" Picture
    sudo mkdir -p "/Library/User Pictures/Office/"
    sudo cp -f "${HOME}/Downloads/os-setup/macos/imgs/poaoffice.tif" "/Library/User Pictures/Office/poaoffice.tif"
    sudo dscl . create "/Users/${USER}" Picture "/Library/User Pictures/Office/poaoffice.png"
    sudo "${HOME}/Downloads/os-setup/macos/set-user-picture.sh" "${USER}" "/Library/User Pictures/Office/poaoffice.tif"
    sudo AssetCacheManagerUtil reloadSettings
}

macos_system_settings()
{
    # Set system theme dark
    osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

    # Set language to English
    lang=$(sudo languagesetup <<< q | grep "English" -m1 | cut -d")" -f1 | sed "s/ //g")
    sudo languagesetup <<< "${lang}" &> /dev/null

    # Set keyboard to en_US
    rm -rf "~/Library/Preferences/com.apple.HIToolbox.plist"
    sudo defaults write ${plist%.*} AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.US"
    sudo killall SystemUIServer

    # Enable tap to click
    sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Reset password policies, (if they were changed by MDMs)
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
    dockutil --remove "TextEdit"
    dockutil --remove "TV"

    # Add some apps in dock
    dockutil --add "/System/Applications/Utilities/Terminal.app"
    dockutil --add "/System/Applications/FindMy.app"
    dockutil --add "/Applications/Google Chrome.app"
    dockutil --add "/Applications/Chat.app"
    dockutil --add "/Applications/Sublime Text.app"

    # Set smaller dock size
    defaults write com.apple.dock tilesize -integer 48
    killall Dock
}

update_zsh_permissions()
{
    zsh_path="/usr/local/share/zsh"
    sudo chown -R "$(whoami)" "${zsh_path}"
    sudo chown -R "$(whoami)" "${zsh_path}"/site-functions
    chmod u+w "${zsh_path}"
    chmod u+w "${zsh_path}"/site-functions
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

    clone_os_setup_repo

    macos_system_settings

    if [[ "${USER}" == "poaoffice" ]]; then
        set_hostname
        configure_login_window
        set_custom_user_picture
    fi

    configure_finder

    collect_computer_info # warranty info requires python3, xcode_cli_tools comes with it

    kill_background_tasks
}

main "$@"

