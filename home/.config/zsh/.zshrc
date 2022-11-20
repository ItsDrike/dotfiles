#!/usr/bin/zsh

# ZSH Options
setopt auto_cd              # cd by typing directory name if it's not a command
setopt auto_list            # automatically list choices on ambiguous completion
setopt auto_menu            # automatically use menu completion
setopt always_to_end        # move cursor to end if word had one match
setopt interactivecomments  # allow comments in interactive mode
setopt magicequalsubst      # enable filename expansion for arguments of form `x=expression`
setopt notify               # report the status of background jobs immediately
setopt numericglobsort      # sort filenames numerically when it makes sense
setopt auto_pushd           # Make cd act as pushd
#setopt correct_all         # autocorrect commands

# oh-my-zsh configuration (DISABLED by default, if you want oh-my-zsh, uncomment these)
#export ZSH="/usr/share/oh-my-zsh"
#ZSH_THEME="af-magic"
#UPDATE_ZSH_DAYS=8
#ENABLE_CORRECTION="false"
#source $ZSH/oh-my-zsh.sh # Run oh-my-zsh

# ZSH files setup (don't clutter home)
export ZSH_CACHE="$HOME/.cache/zsh"
export HISTFILE="$ZSH_CACHE/history"
export ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-$ZSH_VERSION"
mkdir -p "$ZSH_CACHE"

# Auto-remove home clutter
[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful
[ -f ~/.bash_history ] && rm ~/.bash_history

# History configuration
export HISTSIZE=10000
export SAVEHIST=10000
setopt appendhistory            # save history entries as soon as they are entered
setopt hist_ignore_space        # ignore commands that start with space
setopt hist_verify              # show commands with history expansion to user before running it
setopt extended_history         # record command start time
#setopt hist_ignore_dups        # ignore duplicated commands history list
#setopt hist_expire_dups_first  # delete duplicates first when HISTFILE size exceeds HISTFILE
#setopt share_history           # share command history data between terminals

# Completion features (tab)
autoload -Uz compinit
zmodload -i zsh/complist                # load completion list
compinit -d $ZSH_COMPDUMP               # Specify compdump file
comp_options+=(globdots)                # Enable completion on hidden files.
zstyle ':completion:*' menu select      # select completions with arrow keys
zstyle ':completion:*' group-name ''    # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

# Color support
#autoload -U colors && colors

# Setup aliases
[ -f ~/.config/shell/aliases ] && source ~/.config/shell/aliases
# Load handlers
[ -f ~/.config/shell/handlers ] && source ~/.config/shell/handlers
# Load key bindings
[ -f ~/.config/shell/keybinds ] && source ~/.config/shell/keybinds
# Load prompt
[ -f ~/.config/shell/prompt ] && source ~/.config/shell/prompt

# Define TMOUT timeout for TTY and root
# [ -z "$DISPLAY" ] && export TMOUT=800
# [ $UID -eq 0 ] && export TMOUT=600

# Load extensions (should be last)
source /usr/share/zsh/site-functions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/site-functions/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/src/z.lua/z.lua.plugin.zsh
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
