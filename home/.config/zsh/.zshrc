#!/usr/bin/zsh

#########################
# History Configuration #
#########################
export HISTSIZE=12000
export SAVEHIST=10000

# If the internal history needs to be trimmed to add the current command line, setting this
# option will cause the oldest history event that has a duplicate to be lost before losing a
# unique event from the list. You should be sure to set the value of HISTSIZE to a larger
# number than SAVEHIST in order to give you some room for the duplicated events, otherwise
# this option will behave just like HIST_IGNORE_ALL_DUPS once the history fills up with unique
# events.
setopt hist_expire_dups_first

# When searching for history entries in the line editor, do not display duplicates of a line
# previously found, even if the duplicates are not contiguous.
setopt hist_find_no_dups

# If a new command line being added to the history list duplicates an older one, the older
# command is removed from the list (even if it is not the previous event).
setopt hist_ignore_all_dups

# Remove command lines from the history list when the first character on the line is a space,
# or when one of the expanded aliases contains a leading space. Only normal aliases (not
# global or suffix aliases) have this behaviour. Note that the command lingers in the internal
# history until the next command is entered before it vanishes, allowing you to briefly reuse
# or edit the line. If you want to make it vanish right away without entering another command,
# type a space and press return.
setopt hist_ignore_space

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt hist_save_no_dups

# This option works like APPEND_HISTORY except that new history lines are added to the $HISTFILE
# incrementally (as soon as they are entered), rather than waiting until the shell exits.
setopt inc_append_history

# When using history expansion (such as with sudo !!), on enter, first show the expanded command
# and only run it after confirmation (another enter press)
setopt hist_verify

###############
# ZSH Options #
###############

setopt auto_cd              # cd by typing directory name if it's not a command
setopt auto_list            # automatically list choices on ambiguous completion
setopt auto_menu            # automatically use menu completion
setopt always_to_end        # move cursor to end if word had one match
setopt interactivecomments  # allow comments in interactive mode
setopt magicequalsubst      # enable filename expansion for arguments of form `x=expression`
setopt notify               # report the status of background jobs immediately
setopt numericglobsort      # sort filenames numerically when it makes sense
setopt auto_pushd           # Make cd act as pushd
setopt globdots             # Match files starting with . without specifying it (cd <TAB>)
#setopt correct_all         # autocorrect commands

##################
# Autocompletion #
##################

autoload -Uz compinit
zmodload -i zsh/complist                # load completion list
compinit -d $ZSH_COMPDUMP               # Specify compdump file
zstyle ':completion:*' menu select      # select completions with arrow keys
zstyle ':completion:*' group-name ''    # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

#################
# Custom config #
#################

# Setup aliases
[ -f ~/.config/shell/aliases ] && source ~/.config/shell/aliases
# Load handlers
[ -f ~/.config/shell/handlers ] && source ~/.config/shell/handlers
# Load key bindings
[ -f ~/.config/shell/keybinds ] && source ~/.config/shell/keybinds
# Load prompt
[ -f ~/.config/shell/prompt ] && source ~/.config/shell/prompt

#####################
# Automatic Cleanup #
#####################

[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful
[ -f ~/.bash_history ] && rm ~/.bash_history

# Make sure ZSH_CACHE dir exists, avoiding zsh to create it's cache files
# in $HOME
mkdir -p "$ZSH_CACHE"

########
# Misc #
########

# Color support
#autoload -U colors && colors

# Define TMOUT timeout for TTY and root
# [ -z "$DISPLAY" ] && export TMOUT=800
# [ $UID -eq 0 ] && export TMOUT=600

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

#########################
# Zgenom Plugin Manager #
#########################

# Load zgenom (plugin manager for ZSH)
source "${ZDOTDIR}/.zgenom/zgenom.zsh"

# Check for zgenom updates
# This does not increase startup time
zgenom autoupdate

# If the init script doesn't exist yet
if ! zgenom saved; then
    zgenom load skywind3000/z.lua
    zgenom load akash329d/zsh-alias-finder
    zgenom load clarketm/zsh-completions
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zdharma-continuum/fast-syntax-highlighting

    # Generate the init script from plugins above
    zgenom save
fi

