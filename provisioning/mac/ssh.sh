#!/usr/bin/env bash

#
# Set up SSH Keys
#

mkdir -p ~/.ssh

doing "Listing ~/.ssh directory contents..."
ls -al ~/.ssh

echo -e "Do you want to continue creating keys? [y/n]: "
read CONTINUE

if [ "$CONTINUE" = "y" ]; then
  echo -e "\nEnter the email address you want to use and press [ENTER], then follow instructions: "
  read USER_EMAIL
  ssh-keygen -t ed25519 -C "$USER_EMAIL"

  doing "Starting the ssh-agent in the background..."
  eval "$(ssh-agent -s)"

  echo -e "\nChoose the private key file you want to add (that is, not the one ending in .pub)..."
  select FILENAME in ~/.ssh/*;
  do
       echo -e "You chose ${cyan}$FILENAME${reset} as the private key you want to add."
       break
  done

  # echo -e -n -e "\n\nEnter the file name you used above (just the filename, not the full path, i.e. 'id_rsa') and press [ENTER]: "
  # read FILENAME
#   ssh-add -K $FILENAME
  ssh-add --apple-use-keychain "$FILENAME"

  doing "Copying the public key to the clipboard..."
  pbcopy < "$FILENAME.pub"

  echo -e "\nCopied!."
  echo -e "\nALL DONE."
fi

# WARNING: The -K and -A flags are deprecated and have been replaced
#          by the --apple-use-keychain and --apple-load-keychain
#          flags, respectively.  To suppress this warning, set the
#          environment variable APPLE_SSH_ADD_BEHAVIOR as described in
#          the ssh-add(1) manual page.
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Permissions 0644 for '/Users/mikedulle/.ssh/id_rsa' are too open.
# It is required that your private key files are NOT accessible by others.
# This private key will be ignored.
