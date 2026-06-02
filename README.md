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

### Bootstrap a fresh machine

`bootstrap.sh` is intentionally minimal and safe to re-run: it makes sure `git`
is available (on macOS that means installing the Xcode Command Line Tools, since
there's no standalone git), clones this public repo to `~/Dotfiles`, and runs
`install.sh`. Everything else — Homebrew, the GitHub CLI, languages, apps, and
the private secrets — is handled afterward by `provision.sh`. Run the script:

``` bash
curl -fsSL https://raw.githubusercontent.com/dodecasphere/dotfiles/master/bootstrap.sh | bash
```

Then provision — the bootstrapper prints the exact command for your OS:

#### MacOS
``` bash
cd ~/Dotfiles && ./provision.sh --mac
```

#### Linux
``` bash
cd ~/Dotfiles && ./provision.sh --linux
```

### Secrets

This public repo contains **no** secrets. SSH keys and API tokens live in a
separate **private** repo, `dodecasphere/dotfiles-secrets`. During provisioning,
[`provisioning/mac/secrets.sh`](provisioning/mac/secrets.sh) uses your GitHub
login (from `gh auth login`) to clone it into `~/.dotfiles-secrets` and install:

- SSH keys → `~/.ssh` (with correct permissions)
- token exports (`secrets.env`) → sourced by your shell
