ZSH_CACHE="$HOME/.cache/zsh"

# History in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZSH_CACHE/history

# Move .zsh-update to $ZSH_CACHE
[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update



# Export oh-my-zsh location as $ZSH
 export ZSH="/usr/share/oh-my-zsh"

# Set theme
ZSH_THEME="af-magic"

# How often should zsh be updated
export UPDATE_ZSH_DAYS=5

# Enable command auto-correction
ENABLE_CORRECTION="false"

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh


# Enable colors
autoload -U colors && colors

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Setup aliases
[ -f ~/.config/sh/.aliases ] && source ~/.config/sh/.aliases

# XDG Exports
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ~/ Clean-up
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority" # Might break some DMs
export WGETRC="$HOME/.config/wget/wgetrc"
export LESSHISTFILE="-"
export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc


# Load zsh-syntax-highlighting (should be last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#neofetch --cpu_temp C --gtk2 off --gtk3 off --color_blocks on --pixterm
