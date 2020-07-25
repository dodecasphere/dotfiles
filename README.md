          _       _    __ _ _
         | |     | |  / _(_) |
       __| | ___ | |_| |_ _| | ___  ___
      / _` |/ _ \| __|  _| | |/ _ \/ __|
     | (_| | (_) | |_| | | | |  __/\__ \
    (_)__,_|\___/ \__|_| |_|_|\___||___/

## Setup
Clone repo and run `./install.sh`

Install without git
```bash
cd; mkdir dotfiles; cd dotfiles; \
curl -#L https://github.com/dodecasphere/setup/tarball/master | \
tar -xzv --strip-components 1; \
./install.sh
```

## Provisioning
#### MacOS
`./provision.sh --mac`

#### Linux
`./provision.sh --linux`
