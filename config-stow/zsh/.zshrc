# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# aliases
alias ls='ls --color=auto'
alias ll='ls -lav -al'
alias l='ls -lav --ignore=.?*'
alias la='ls --color=auto -av'

# snake=(for file in *; do mv "$file" "$(echo $file | tr '_' ' ')" ; done)

# config file locations
nvim=$HOME'/.config/nvim/init.lua'
conf=$HOME'/.dotEndeavor/config-stow'
raw=$HOME'/.dotEndeavor/raw-backup'
i3=$conf'/i3/.config/i3/config'
zsh=$conf'/zsh/.zshrc'

# script location
scripts=$conf'/i3/.config/i3/scripts'

# zoxide
# _ZO_ECHO=1      # set to 1 to print matching directory
eval "$(zoxide init zsh)"

# Use powerline
USE_POWERLINE="false"

export PATH="$PATH:/bin/butler/"

export TERMINAL=alacritty
export BROWSER=google-chrome-stable
export EDITOR=nvim

# zsh fuszzy search
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

