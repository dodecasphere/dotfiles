#!/usr/bin/env zsh

# Main interactive zsh config — the zsh counterpart of `bash_profile` + `bashrc`.
# Loads the same shared dotfiles (colors, path, exports, aliases, functions) so
# the experience matches bash, then layers on zsh-native options, completion,
# key bindings, the prompt, and a couple of subtle enhancements.

# Use the emacs keymap so the readline-style shortcuts documented by `keys`
# (Ctrl+A/E/W, Alt+B/F, …) behave the same as they did under bash.
bindkey -e

# ---------------------------------------------------------------------------
# Load shared dotfiles
# ---------------------------------------------------------------------------

source ~/.colors

# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for dotfile in ~/.{path,exports,aliases,functions,extra}; do
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

# Prompt (zsh port of bash_prompt)
source ~/.zsh_prompt

# ---------------------------------------------------------------------------
# Shell options (zsh equivalents of the bash `shopt` block)
# ---------------------------------------------------------------------------

setopt AUTO_CD            # `**/qux` style: type a dir name to cd into it (bash autocd)
setopt EXTENDED_GLOB      # richer globbing (recursive ** is native in zsh)
setopt NO_CASE_GLOB       # case-insensitive globbing (bash nocaseglob)
setopt AUTO_PUSHD         # cd pushes onto the dir stack — powers the `2`/`3`/`d` aliases
setopt PUSHD_IGNORE_DUPS  # don't clutter the stack with duplicates
setopt PUSHD_SILENT       # don't print the stack on every pushd/popd
# (recursive globbing and window-resize tracking are automatic in zsh; the
#  aggressive `CORRECT` autocorrect is intentionally left off to avoid surprises)

# ---------------------------------------------------------------------------
# History (mirrors exports' HISTCONTROL=ignoreboth + histappend, zsh-style)
# ---------------------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
setopt HIST_IGNORE_DUPS     # ignoredups
setopt HIST_IGNORE_SPACE    # ignorespace  (together = bash ignoreboth)
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY   # write as you go (bash histappend)
setopt SHARE_HISTORY        # share history across concurrent sessions

# ---------------------------------------------------------------------------
# Completion (replaces the bash_completion + `complete` setup)
# ---------------------------------------------------------------------------

# Make Homebrew's completions available to compinit.
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
    # zsh-completions, if installed via brew, ships extra completion functions.
    [ -d "$(brew --prefix)/share/zsh-completions" ] && FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi

autoload -Uz compinit && compinit
# Let zsh also consume bash-style completion scripts (e.g. brew's bash dir).
autoload -Uz bashcompinit && bashcompinit

# Tab-complete `g` just like `git` (bash did this via `complete -F _git g`).
compdef g=git 2>/dev/null

# Case-insensitive matching (inputrc: completion-ignore-case on).
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Colorize completion listings using LS_COLORS (inputrc: visible-stats-ish).
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Ask before listing huge result sets (inputrc: completion-query-items 200).
LISTMAX=200

# fzf-tab: render completion menus through fzf. Not a Homebrew formula, so
# clone it on first run, then source (must come after compinit, before the
# syntax-highlighting plugin below).
FZF_TAB_DIR="$HOME/.zsh/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ] && command -v git &>/dev/null; then
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR" &>/dev/null
fi
[ -f "$FZF_TAB_DIR/fzf-tab.plugin.zsh" ] && source "$FZF_TAB_DIR/fzf-tab.plugin.zsh"

# ---------------------------------------------------------------------------
# Key bindings (translated from inputrc)
# ---------------------------------------------------------------------------

# Up/Down: search history using the already-typed text as a prefix
# (inputrc bound \e[A / \e[B to history-search-backward/forward). Bind both the
# normal and application-cursor-mode sequences so it works in every terminal.
bindkey '^[[A' history-beginning-search-backward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OB' history-beginning-search-forward

# Alt/Meta + Delete deletes the preceding word (inputrc: "\e[3;3~": kill-word).
bindkey '^[[3;3~' kill-word

# ---------------------------------------------------------------------------
# Enhancements (zsh-only niceties)
# ---------------------------------------------------------------------------

if type brew &>/dev/null; then
    _brew_prefix="$(brew --prefix)"
    # Fish-like grey suggestions from history as you type.
    [ -f "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
        source "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    # Syntax highlighting MUST be sourced last to wrap the line editor correctly.
    [ -f "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
        source "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    unset _brew_prefix
fi

# ---------------------------------------------------------------------------
# Tooling
# ---------------------------------------------------------------------------

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide — smarter `cd` (provides `z` and `zi`).
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ---------------------------------------------------------------------------
# Laravel Herd (PHP + Node/NVM). Herd may append its own block on first run;
# keep this the single copy and delete any duplicate it adds.
# ---------------------------------------------------------------------------

# NVM (bundled with Herd)
export NVM_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Herd PHP binary + per-version php.ini scan dirs
export PATH="/Users/michaeldulle/Library/Application Support/Herd/bin/":$PATH
export HERD_PHP_74_INI_SCAN_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/php/74/"
export HERD_PHP_82_INI_SCAN_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/php/82/"
export HERD_PHP_83_INI_SCAN_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/php/83/"
export HERD_PHP_85_INI_SCAN_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/php/85/"

# ---------------------------------------------------------------------------
# Machine-specific / locally-added config (PATH, env, tool init). Sourced last
# so it can override anything above. Not tracked in git.
# ---------------------------------------------------------------------------
[ -r ~/.shell.local ] && source ~/.shell.local


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/michaeldulle/Library/Application Support/Herd/config/php/84/"
