#!/usr/bin/env bash

#
# Set up Git
#

# Machine-local, OS-specific git config — included by the shared gitconfig
# (which git silently skips when this file is absent, e.g. on Linux).
doing "Writing ~/.gitconfig-os (macOS credential helper)..."
cat > "$HOME/.gitconfig-os" <<'EOF'
[credential]
	helper = osxkeychain
EOF

function test_github {
  ssh -T git@github.com 2>&1 | grep --silent "You've successfully authenticated"
}

test_github

if [ $? -ne 0 ]; then
  pbcopy < ~/.ssh/id_rsa.pub
  echo "We've copied your public key to the clipboard, now add it to your Github profile"
  open "https://github.com/settings/ssh"

  press_key_to_continue "Finished? "
  echo ""

  until test_github; do
    echo "Hmm ... we seem to be having trouble connecting to github.  Please double check your settings"
    press_key_to_continue "Try again? "
    echo ""
  done
fi

test_github
