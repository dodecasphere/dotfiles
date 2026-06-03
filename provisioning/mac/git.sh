#!/usr/bin/env bash

#
# Set up Git
#

function test_github {
  ssh -T git@github.com 2>&1 | grep --silent "You've successfully authenticated"
}

test_github

if [ $? -ne 0 ]; then
  pbcopy < ~/.ssh/id_rsa.pub
  echo "We've copied your public key to the clipboard, now add it to your Github profile"
  open "https://github.com/settings/ssh"

  read -p "Finished? " -n 1 -r
  echo ""

  while [ $? -ne 0 ]; do
    echo "Hmm ... we seem to be having trouble connecting to github.  Please double check your settings"
    read -p "Try again? " -n 1 -r
    echo ""
    test_github
  done
fi

test_github
