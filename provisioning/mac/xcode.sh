#!/usr/bin/env bash

#
# Install XCode
#

doing "Installing XCode Command Line Utilities..."
xcode-select --install

doing "Installing XCode..."

function check_for_xcode {
  xcode-select --print-path | grep '/Applications/Xcode.app/Contents/Developer' > /dev/null 2>&1
  HAS_FULL_XCODE=$?
}

check_for_xcode

if [ ${HAS_FULL_XCODE} -eq 0 ]; then
  line "XCode is already installed"
else
  while [ ${HAS_FULL_XCODE} -ne 0 ]; do
    line "XCode is not installed. Please install it via the GUI."
    xcode-select --install
    press_key_to_continue

    line "Now also install the XCode command line tools via the GUI."
    xcode-select --install
    press_key_to_continue

    line "You now need to accept the license for XCode; read ALL the"
    line "way to the end and type 'agree' as instructed."
    sudo xcrun cc
    press_key_to_continue

    check_for_xcode
  done
fi
