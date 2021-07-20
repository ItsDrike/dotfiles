#!/usr/bin/zsh

source /etc/profile

# ZSH Options
setopt auto_cd              # cd by typing directory name if it's not a command
setopt auto_list            # automatically list choices on ambiguous completion
setopt auto_menu            # automatically use menu completion
setopt always_to_end        # move cursor to end if word had one match
setopt interactivecomments  # allow comments in interactive mode
setopt magicequalsubst      # enable filename expansion for arguments of form `x=expression`
setopt notify               # report the status of background jobs immediately
setopt numericglobsort      # sort filenames numerically when it makes sense
#setopt correct_all         # autocorrect commands

# ZSH files cleanup
export ZSH_CACHE="$HOME/.cache/zsh"
export ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-$ZSH_VERSION" # for auto/tab completion

[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful
[ -f ~/.bash_history ] && rm ~/.bash_history

# History configuration
HISTFILE="$ZSH_CACHE/history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory			# save history entries as soon as they are entered
setopt hist_ignore_space        # ignore commands that start with space
setopt hist_verify              # show commands with history expansion to user before running it
#setopt hist_ignore_dups        # ignore duplicated commands history list
#setopt hist_expire_dups_first  # delete duplicates first when HISTFILE size exceeds HISTFILE
#setopt share_history           # share command history data between terminals

# oh-my-zsh configuration (DISABLED by default, if you want oh-my-zsh, uncomment these)
#export ZSH="/usr/share/oh-my-zsh"
#ZSH_THEME="af-magic"
#UPDATE_ZSH_DAYS=8
#ENABLE_CORRECTION="false"
#source $ZSH/oh-my-zsh.sh # Run oh-my-zsh

# Completion features (tab)
autoload -Uz compinit
zmodload -i zsh/complist
compinit -d $ZSH_COMPDUMP
comp_options+=(globdots)
zstyle ':completion:*' menu select   # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completio

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

# Load extensions (should be last)
. /usr/share/zsh/site-functions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
. /usr/share/zsh/site-functions/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
eval "$(lua ~/.local/src/z.lua/z.lua --init zsh enhanced)"

