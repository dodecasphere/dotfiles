#!/usr/bin/env bash

#
# Set up Git — verify GitHub SSH auth works. The keys themselves come from the
# private secrets repo (provisioning/mac/secrets.sh, portable, sourced before
# this). Same flow as provisioning/mac/git.sh minus pbcopy/open: headless box,
# so the public key is printed to paste from the terminal instead.
#

function test_github {
  ssh -T git@github.com 2>&1 | grep --silent "You've successfully authenticated"
}

test_github

if [ $? -ne 0 ]; then
  echo "GitHub SSH auth failed. Add a public key to your GitHub profile:"
  echo "  https://github.com/settings/ssh"
  echo ""
  echo "Public keys on this machine:"
  for pub in "$HOME"/.ssh/*.pub; do
    [ -e "$pub" ] || continue
    echo ""
    cat "$pub"
  done

  press_key_to_continue "Finished? "
  echo ""

  until test_github; do
    echo "Hmm ... we seem to be having trouble connecting to github.  Please double check your settings"
    press_key_to_continue "Try again? "
    echo ""
  done
fi

test_github
