#!/usr/bin/env bash

#
# Install Homebrew on Linux (linuxbrew). The `path` file picks it up in future
# shells; shellenv is eval'd here so the rest of this provisioning run can use
# brew immediately.
#

BREW_PREFIX="/home/linuxbrew/.linuxbrew"

doing "Homebrew..."
if [ -x "$BREW_PREFIX/bin/brew" ]; then
  echo "Homebrew already installed ($("$BREW_PREFIX/bin/brew" --version | head -n 1)) — skipping"
else
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Hard stop if brew still isn't there (failed installer) — everything after
# this depends on it, so continuing would just cascade errors.
if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
  echo "Homebrew install failed — brew not found at $BREW_PREFIX/bin/brew. Fix the error above and re-run." >&2
  exit 1
fi

eval "$("$BREW_PREFIX/bin/brew" shellenv)"
