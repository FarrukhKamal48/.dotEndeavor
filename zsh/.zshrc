# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# aliases
alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'
alias l='ls -lav --ignore=.?*'
alias la='ls --color=auto -al'


# config file locations
i3rc='/home/farrukh/.config/i3/config'

# Use powerline
USE_POWERLINE="false"

# export FrameworkPathOverride="/usr/lib/mono/4.8-api/"
export PATH="$PATH:/bin/butler/"

export TERMINAL=alacritty
export BROWSER=brave
export EDITOR=nvim

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


