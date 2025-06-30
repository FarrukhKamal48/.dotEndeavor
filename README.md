## Install `stow`

```
yay -S stow
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
stow -vt ~ <name of config>
```
Stow essentially pretends that it is in the target directoy specified (home in this case), and then creates symlinks according to directory structure specified in `<name of config>`

## `raw-backup` ?
This contains files which are not necessarily 'dot files'. It contains things like browser extensions etc.

The `raw-backup/browser` folder just contains brave settings and extension configs. So far, vimium config has been added.

## `config-sys` ?

This contains all config files that are not in the home folder and thus require sudo permissions to be placed in their destinations.
Additionally, symlinks between home folder locations and other locations is not possible.

The directory structure in each of these folders dictates where they are supposed to be placed in (just like `config-stow`) but instead the target directory is `/`

The `config-sys/zsh` folder contains an exact copy of the manjaro zsh config. After it has been placed in its appropriate locaion, you have to install `powerlevel10k` zsh theme (using AUR).

The `config-sys/libinput` folder contains libinput configuration for my periferals (mosue, touchpad, logitec keyboard) 

## Ssh Setup

First make sure you have `openssh` package installed.

Then you have to start the `ssh-agent` :
```
eval "$(ssh-agent -s)"
```

Generate the ssh keys (it will ask you for path to store the keys, best to use the `.ssh` folder in you home directory):
```
ssh-keygen -t ed25519 -C "<your email>"
```

Add the private key to agent:
```
ssh-add <path to PRIVATE key>
```

Now the final step, and this is the most important.

Create a file in `~/.ssh/` called `config` and add the following lines to it:
```
Host *
	AddKeysToAgent yes
	IdentityFile <path to PRIVATE key>
```

## GTK themes

Clone [Tokyonight](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) or [Catppuccin](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme).

cd into the repo and run: 
```
sudo themes/install.sh -d /usr/share/themes -t default -c dark
```

You can run `themes/install.sh -h` for usage

Now you need to tell `gtk` to use the theme

Paste the following into `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` :
```
[Settings]
gtk-application-prefer-dark-theme=true
gtk-button-images=true
gtk-cursor-blink=true
gtk-cursor-blink-time=1000
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-decoration-layout=icon:minimize,maximize,close
gtk-enable-animations=true
gtk-font-name=Noto Sans,  10
gtk-icon-theme-name=<name of theme as it appears in /usr/share/icons/>
gtk-menu-images=true
gtk-modules=colorreload-gtk-module
gtk-primary-button-warps-slider=true
gtk-sound-theme-name=ocean
gtk-theme-name=<name of theme as it appears in /usr/share/themes/>
gtk-toolbar-style=3
gtk-xft-dpi=98304
```

The themes should work now but if you want additional configuration for colors run the following:
```
yay -S lxappearance lxsession
```

Now put lxsession in your `i3` config or `.xinitrc`

You can now configure colors in `lxappearance`

