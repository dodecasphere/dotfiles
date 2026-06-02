          _       _    __ _ _
         | |     | |  / _(_) |
       __| | ___ | |_| |_ _| | ___  ___
      / _` |/ _ \| __|  _| | |/ _ \/ __|
     | (_| | (_) | |_| | | | |  __/\__ \
    (_)__,_|\___/ \__|_| |_|_|\___||___/

## Setup

On a sparkling fresh installation of macOS, grab the latest software updates:

```
sudo softwareupdate -i -a
```

### Bootstrap a fresh Mac (recommended)

`bootstrap.sh` does everything end-to-end and is safe to re-run: installs the
Xcode Command Line Tools, Homebrew, and the GitHub CLI, authenticates to GitHub
in the **browser** (no SSH key or token to create — and this is what unlocks the
private secrets repo, see below), clones this repo to `~/Dotfiles`, and runs
`install.sh`.

This repo is public, so the script can be run straight from its raw URL:

``` bash
curl -fsSL https://raw.githubusercontent.com/dodecasphere/dotfiles/master/bootstrap.sh | bash
```

Then provision:

``` bash
cd ~/Dotfiles && ./provision.sh --mac
```

#### Running the `gh` flow by hand

The same steps manually — the `gh auth login` step prints a one-time code and
opens <https://github.com/login/device> for you to authorize:

``` bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install gh
gh auth login --hostname github.com --git-protocol https --web
gh repo clone dodecasphere/dotfiles ~/Dotfiles
cd ~/Dotfiles && ./install.sh
```

### Secrets

This public repo contains **no** secrets. SSH keys and API tokens live in a
separate **private** repo, `dodecasphere/dotfiles-secrets`. During provisioning,
[`provisioning/mac/secrets.sh`](provisioning/mac/secrets.sh) uses your GitHub
login (from `gh auth login`) to clone it into `~/.dotfiles-secrets` and install:

- SSH keys → `~/.ssh` (with correct permissions)
- token exports (`secrets.env`) → sourced by your shell, which fill in
  `${FONTAWESOME_NPM_TOKEN}` in `npmrc` and `EXPOSE_TOKEN` for Expose.

### Alternative install methods

Clone manually (public repo — no auth needed for this part), then run the
secrets/provision steps as above:

``` bash
git clone https://github.com/dodecasphere/dotfiles.git ~/Dotfiles   # or git@…:dodecasphere/dotfiles.git over SSH
cd ~/Dotfiles && ./install.sh
```

## Provisioning

Run one of the following commands depending on which operating system you're on:

#### MacOS
``` bash
./provision.sh --mac
```

#### Linux
``` bash
./provision.sh --linux
```
