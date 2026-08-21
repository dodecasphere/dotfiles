#!/usr/bin/env zsh

# Login-shell environment for zsh.
#
# PATH and the Homebrew environment are centralized in ~/.path, which is sourced
# by ~/.zshrc (interactive). Tools that inject login-shell setup can append here,
# or add machine-specific bits to ~/.shell.local.

# Phoenix onboarding kit
eval "$(/opt/homebrew/bin/brew shellenv)"

# Phoenix onboarding kit
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
