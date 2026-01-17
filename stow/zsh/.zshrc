# zmodload zsh/zprof
# =============================================================================
# INSTANT PROMPT (MUST BE AT THE VERY TOP FOR MAX SPEED)
# =============================================================================
# This is the most important feature for a fast-feeling shell.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# HISTORY
HISTFILE=~/.zhistory; HISTSIZE=200000; SAVEHIST=100000
WORDCHARS=${WORDCHARS//\/[&.;]}


# =============================================================================
# ZINIT - PLUGIN MANAGER (TURBO-CHARGED)
# =============================================================================

# Install zinit if not found
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# For some reason zinit aliases zi to itself
unalias zi

# Zinit Annexes (for extra functionality)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# --- Plugins ---
# We load P10k immediately for the prompt, everything else is deferred with `lucid`.
# This means it loads in the background *after* you can start typing.

# Powerlevel10k Theme (load immediately)
zinit light romkatv/powerlevel10k


# Auto Suggestions (defer)
zinit light zsh-users/zsh-autosuggestions


# FZF-based history search (defer)
zinit ice lucid wait'0' rust; zinit light joshskidmore/zsh-fzf-history-search


# History Substring Search (defer)
zinit ice lucid wait'0' rust; zinit light zsh-users/zsh-history-substring-search

# FZF and Zoxide integration (defer)


# Syntax Highlighting (defer)
zinit ice lucid wait'0' rust; zinit light zsh-users/zsh-syntax-highlighting

# Cache zoxide init for faster startup
local zoxide_cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide-init.zsh"
if [[ ! -f "$zoxide_cache_file" || "$(whence -p zoxide)" -nt "$zoxide_cache_file" ]]; then
  zoxide init zsh >| "$zoxide_cache_file"
fi
source "$zoxide_cache_file"

# zinit light ajeetdsouza/zoxide



# =============================================================================
# POWERLEVEL10K CONFIGURATION
# =============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# COMPLETION SYSTEM (THE ULTIMATE SPEED FIX)
# =============================================================================

# 1. Define storage for generated completions
local completions_dir="${ZDOTDIR:-$HOME}/.zsh/completions"
mkdir -p "$completions_dir"

# 2. Add to fpath (Must be BEFORE compinit)
fpath=("$completions_dir" $fpath)

# --- Generate Static Completions (Carapace/Niri) ---
local carapace_file="$completions_dir/_carapace"
if [[ ! -f "$carapace_file" || "$(whence -p carapace)" -nt "$carapace_file" ]]; then
  command -v carapace >/dev/null && carapace _carapace >| "$carapace_file"
fi
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

local niri_file="$completions_dir/_niri"
if [[ ! -f "$niri_file" || "$(whence -p niri)" -nt "$niri_file" ]]; then
  command -v niri >/dev/null && niri completions zsh >| "$niri_file"
fi

# --- Initialize Compinit (Smart Caching) ---
autoload -Uz compinit
local zcomp_cache_file="${ZDOTDIR:-$HOME}/.zcompdump"

# Logic: If .zsh/completions is newer than the cache file, we MUST re-scan (no -C).
# Otherwise, we use -C for speed.
if [[ -f "$zcomp_cache_file" && "$completions_dir" -nt "$zcomp_cache_file" ]]; then
  # Cache is old/stale because we generated a new LLM script. Rebuild it.
  compinit -i -d "$zcomp_cache_file"
elif [[ -f "$zcomp_cache_file" ]]; then
  # Cache is fresh. Use it blindly for speed.
  compinit -i -C -d "$zcomp_cache_file"
else
  # No cache exists. Build it.
  compinit -i -d "$zcomp_cache_file"
fi

# Initializing Zoxide
# eval "$(zoxide init zsh)"


# =============================================================================
# 6. LLM FALLBACK SETUP (My AI Script)
# =============================================================================
if [[ -f "$HOME/.zsh/llm-completer.zsh" ]]; then
    source "$HOME/.zsh/llm-completer.zsh"
fi

# =============================================================================
# COMPLETION SYSTEM STYLES
# =============================================================================

# --- Matching Behavior (HOW zsh finds completions) ---
zstyle ':completion:*' matcher-list '' \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# --- Completion Strategies (WHAT zsh does if no direct match) ---
zstyle ':completion:*' completer _complete _correct

# --- User Interface & Experience ---
zstyle ':completion:*:descriptions' format '%B%F{blue}%d%f%b'
zstyle ':completion:*:menu' select=1 prompt='%B%F{yellow}»%f%b '
zstyle ':completion:*:correct:*' max-errors 2
zstyle ':completion:*:correct:*' prompt 'zsh: correct '%e' to '%c' [y,n,a,e]? '
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# --- Git Specific Completion Styles ---

# 1. Define the logical order of command groups. (You already have this)
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# 2. **THE FIX:** Disable the separate group headers.
zstyle ':completion:*:git:*' group-name ''

# 3. Format the descriptions to be colored and bold. (You already have this)
zstyle ':completion:*:git:*' descriptions '%B%F{blue}%d%f%b'
# zstyle ':completion:*' rehash true

# --- Smarter Logic ---
zstyle ':completion:*' ambiguous ''
zstyle ':completion:*:manuals' auto-description 'man %d'

# --- File & Path Specifics ---
zstyle ':completion:*:files' file-sort modification
zstyle ':completion:*:*:(^cd):*:files' ignored-patterns '*~' '*.o' '*.pyc' 'node_modules'

# =============================================================================
# SHELL OPTIONS, HISTORY, KEYBINDINGS, ENV, ALIASES, ETC. (UNCHANGED)
# =============================================================================

# OPTIONS
setopt extendedglob nocaseglob numericglobsort nobeep autocd multios
setopt appendhistory inc_append_history hist_ignore_all_dups hist_ignore_space hist_verify


# KEYBINDINGS
# bindkey '^L' vi-forward-word # Right arrow for vi-style incremental acceptance
bindkey -e; bindkey '^[[H' beginning-of-line; bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char; bindkey '^[[1;5C' forward-word; bindkey '^[[1;5D' backward-word
bindkey '^H' backward-kill-word; bindkey '^[[Z' undo
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down

# ENVIRONMENT & PATH

source "$HOME/.secrets/api_keys.zsh"

export EDITOR='nvim' VISUAL='nvim'
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore --glob "!.git/*"'
export RUSTC_WRAPPER="sccache"
export _JAVA_AWT_WM_NONREPARENTING=1 CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export LS_COLORS=$(vivid generate tokyonight-night)
PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.modular/bin:$HOME/programs/synlig:$HOME/programs/sv2v/bin:$HOME/repos/riscv-pk/build:$HOME/.lmstudio/bin:$PATH"
PATH="/tools/Xilinx/Vivado/2019.2/bin:/opt/intelFPGA/20.1/modelsim_ase/bin:/opt/spike/bin:/opt/riscv64/bin:/opt/riscv32/bin:/opt/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/:$PATH"
export PATH

# ROCM vars
export HSA_OVERRIDE_GFX_VERSION=11.0.0
export PYTORCH_ROCM_ARCH=gfx1100
export HSA_ENABLE_COARSE_GRAIN_BUFFER=1


# ALIASES
alias ls='exa --icons'; alias ll='exa -alh --icons'; alias la='exa -a --icons';
alias cd='z'
alias dictate='cd && cd repos/dictate && uv run main.py' 
alias ipty='jupyter nbconvert --to script'
alias tree='exa --tree'; alias cat='bat -p'; alias pclip="pwd | xclip -selection clipboard"
alias rd="rm -rf"; alias zd="j"
alias fp="fzf --preview 'bat --style=numbers --color=always {}'"
alias f='cd "$(rg --files --no-ignore --hidden --glob "!.git/*" . | fzf-tmux -p --preview "bat --color=always {}")"'
alias rstart='systemctl reboot'; alias off='systemctl poweroff'
alias nmc='nmcli device wifi rescan && sleep 5 && nmcli connection up'
alias nmr='nmcli device wifi rescan && sleep 5 && nmcli device wifi connect'
alias mwin='sudo mount /dev/nvme0n1p3 /mnt/windows'
alias umwin='sudo umount /dev/nvme0n1p3'
alias dtop='libreoffice --headless --invisible --convert-to pdf'
alias sva='source .venv/bin/activate'
# Your personal script aliases...
alias vslmon='~/VisualSim/VS_LM/StartServer.sh'
alias vslmoff='~/VisualSim/VS_LM/StopServer.sh'
alias vsar='~/VisualSim/VS_AR/VisualSim.sh'
alias vnlmon='~/VisualNeo/VS_LM/StartServer.sh'
alias vnlmoff='~/VisualNeo/VS_LM/StopServer.sh'
alias vnar='~/VisualNeo/VS_AR/VisualSim.sh'

update_terminal_cwd() {
  # $PWD is the current working directory.
  printf "\e]7;file://localhost%s\a" "$PWD:A"
}

# Add the function to the `chpwd` hook array.
# This ensures it runs every time the directory is changed.
# We use add-zsh-hook to avoid overriding other chpwd functions.
autoload -U add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd

# Run the function once at shell startup to set the initial directory.
update_terminal_cwd

# Yazi integration for cd on quit and Zoxide compatibility
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}


# zprof
### End of Zinit's installer chunk

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/uneeb/.lmstudio/bin"
# End of LM Studio CLI section



# --- SSH Agent Startup (Silent, Agent Only - No Auto Key Loading) ---

# Define the file where the agent's environment variables will be stored
SSH_ENV="$HOME/.ssh/ssh-agent.env"

function start_ssh_agent {
    # Start the agent and output the variables (PID, SOCKET) to the environment file.
    # We use 'sed' to remove the 'echo' commands the agent outputs.
    /usr/bin/ssh-agent | sed 's/^echo/#/' > "${SSH_ENV}" 2>/dev/null
    
    # Set proper permissions and load the environment variables into the current shell.
    # All output from the source command is suppressed.
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null 2>&1
}

# 1. Check if the environment file exists
if [[ -f "${SSH_ENV}" ]]; then
    # Load the environment variables from the file silently
    . "${SSH_ENV}" > /dev/null 2>&1
    
    # 2. Check if the PID stored in the file is still a running process (i.e., agent is alive)
    # 'kill -0' checks if a process exists without actually sending a signal. Error output suppressed.
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        # The PID is dead (agent process terminated), start a new agent silently
        start_ssh_agent
    fi
else
    # Environment file not found, start a new agent silently
    start_ssh_agent
fi

# --- END SSH Agent Startup ---

