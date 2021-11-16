#!/bin/bash

# This comes fomr the gist here
# https://gist.github.com/palmerc/5e8dfb37ed46b01c9a6f56ecd58727a7

# USAGE:
# ./userpic.sh USERNAME PICTURE

USERNAME=$1
USERPIC=$2

MAPPINGS='0x0A 0x5C 0x3A 0x2C'
ATTRS='dsRecTypeStandard:Users 2 dsAttrTypeStandard:RecordName externalbinary:dsAttrTypeStandard:JPEGPhoto'

if [ ! -f "${USERPIC}" ]; then
  echo "User image required"
fi

# Check if the username exists otherwise exit
id ${USERNAME} &> /dev/null || ( echo "User does not exist" && exit 1 )

declare -r PICIMPORT="$(mktemp /tmp/${USERNAME}_dsimport.XXXXXX)" || exit 1

printf "%s %s \n%s:%s" "${ATTRS}" "${USERNAME}" "${USERPIC}" > "${PICIMPORT}"

dsimport "${PICIMPORT}" /Local/Default M && echo "Successfully imported ${USERPIC} for ${USERNAME}."

rm "${PICIMPORT}"
