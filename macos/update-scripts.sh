#!/bin/bash

# Get sources
curl -L -O https://github.com/leoheck/os-setup/archive/refs/heads/main.zip
unzip main.zip

# Replace files
mv -f os-setup-main/* .

# Remove leftovers
rm -rf os-setup-main
rm -rf main.zip
