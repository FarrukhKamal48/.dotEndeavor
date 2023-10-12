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

## `raw-backup` ?
This contains files which are not necessarily 'dot files'. 

The `raw-backup/zsh` folder contains an exact copy of the manjaro zsh config, which is to be placed in `usr/share/zsh/`. After which you have to install `powerlevel10k` zsh theme (using AUR).

As for the `raw-backup/browser` folder, it just contains brave settings and extension configs. So far, vimium config config has been added.



