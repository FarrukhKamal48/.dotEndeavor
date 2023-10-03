## Install `stow`

```
yay -S stow
```
or 
```
sudo pacman -S stow
```

## Setup Config

First, clone the repo:
```
git clone git@github.com:FarrukhKamal48/.dotEndeavor.git
```

Then `cd` into `config-stow/`.

Run `stow -ntv ~ <name of config>`, to see what links stow is going to make.

Remove all previous configs before running the following command:
```
stow -tv ~ <name of config>
```
Stow essentially pretends that it is in the target directoy specified (home in this case), and then creates symlinks according to directory structure specified in `<name of config>`
