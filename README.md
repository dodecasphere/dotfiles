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

Run the script:

``` bash
curl -fsSL https://raw.githubusercontent.com/dodecasphere/dotfiles/master/bootstrap.sh | bash
```

Then provision:

#### MacOS
``` bash
cd ~/Dotfiles && ./provision.sh --mac
```

#### Linux
``` bash
cd ~/Dotfiles && ./provision.sh --linux
```
