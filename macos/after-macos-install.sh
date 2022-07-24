#!/bin/bash

https://www.aarondavidpolley.com/macos-setup-assistant-preferences-skip-screens/


defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipAppearance -bool truedefaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipCloudSetup -bool true
defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipiCloudStorageSetup -bool true
defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipPrivacySetup -bool true

defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipSiriSetup -bool true
defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipTrueTone -bool true
defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipScreenTime -bool true
defaults write ~/Downloads/com.apple.SetupAssistant.managed.plist SkipTouchIDSetup -bool true

plutil -convert xml1 ~/Downloads/com.apple.SetupAssistant.managed.plist



set_setup_assistant()
{

}

# https://developer.apple.com/documentation/devicemanagement/setupassistant
# https://macadminsdoc.readthedocs.io/en/master/General/macOS_Installation/Setup_Assistant.html
# Setup Assistant is also called "MacBuddy"
SkipAppearance      -bool true
SkipPrivacySetup    -bool true
SkipScreenTime      -bool true
SkipSiriSetup       -bool true
SkipTrueTone        -bool true
SkipUnlockWithWatch -bool true

# Remover
# - Location (Brazil)
# - Language (US)
# - Migration Assistant 
# - Terms and Conditions
# - Location Services
# - Analitics
# - Screen Time
# - Siri
# - Payment


command line development tools
xcode-select --install
verify: xcode-select -p