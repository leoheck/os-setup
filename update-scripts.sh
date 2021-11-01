#!/bin/bash

# Get sources
curl -L -O https://github.com/leoheck/osx-setup/archive/refs/heads/main.zip
unzip main.zip

# Replace files
mv -f osx-setup-main/* .

# Remove leftovers
rm -rf osx-setup-main
rm -rf main.zip