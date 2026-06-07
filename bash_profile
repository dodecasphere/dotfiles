#!/usr/bin/env bash

source ~/.colors

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for dotfile in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$dotfile" ] && [ -f "$dotfile" ] && source "$dotfile";
done;
unset dotfile;

# Load aliases
for aliasfile in ~/.aliases/*; do
    [ -r "$aliasfile" ] && [ -f "$aliasfile" ] && source "$aliasfile";
done;
unset aliasfile;

# Private secrets (token exports) from the private repo, if it's been cloned.
[ -r ~/.dotfiles-secrets/secrets.env ] && source ~/.dotfiles-secrets/secrets.env

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    complete -o default -o nospace -F _git g;
fi;

if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    . "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# Don't check mail when opening terminal.
unset MAILCHECK

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null
done

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# append to bash_history if Terminal.app quits
shopt -s histappend

# ---------------------------------------------------------------------------
# Laravel Herd (PHP + Node/NVM). Herd may append its own block on first run;
# keep this the single copy and delete any duplicate it adds.
# ---------------------------------------------------------------------------

# NVM (bundled with Herd)
export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Herd PHP binary + per-version php.ini scan dirs
export PATH="$HOME/Library/Application Support/Herd/bin/":$PATH
export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"
export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
export HERD_PHP_85_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/85/"

# zoxide — smarter `cd` (provides `z` and `zi`).
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# ---------------------------------------------------------------------------
# Machine-specific / locally-added config (PATH, env, tool init). Sourced last
# so it can override anything above. Not tracked in git.
# ---------------------------------------------------------------------------
[ -r ~/.shell.local ] && source ~/.shell.local


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
