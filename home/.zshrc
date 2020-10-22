ZSH_CACHE="$HOME/.cache/zsh"

# History in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZSH_CACHE/history

# Move .zsh-update to $ZSH_CACHE
[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update

export ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-$ZSH_VERSION"


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
compinit -d $ZSH_COMPDUMP
comp_options+=(globdots)

# Setup aliases
[ -f ~/.config/sh/aliases ] && source ~/.config/sh/aliases

# XDG Exports
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ~/ Clean-up
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export LESSHISTFILE="-"
export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export KDEHOME="$XDG_CONFIG_HOME"/kde
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export TS3_CONFIG_DIR="$XDG_CONFIG_HOME"/ts3client
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export PYLINTHOME="$XDG_CACHE_HOME"/pylint
export SQLITE_HISTORY=$XDG_DATA_HOME/sqlite_history
export WAKATIME_HOME="$XDG_CONFIG_HOME/wakatime"
export GOPATH="$XDG_DATA_HOME"/go
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter

# Add executable directories into PATH
PATH+=":$HOME/.local/bin"
# Force pipenv to create new enviroments within projects
export PIPENV_VENV_IN_PROJECT=1

# Load zsh-syntax-highlighting (should be last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#neofetch --cpu_temp C --gtk2 off --gtk3 off --color_blocks on --pixterm
