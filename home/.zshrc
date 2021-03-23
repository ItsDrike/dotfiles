#!/usr/bin/zsh

# ZSH Options
setopt auto_cd             # cd by typing directory name if it's not a command
setopt auto_list           # automatically list choices on ambiguous completion
setopt auto_menu           # automatically use menu completion
setopt always_to_end       # move cursor to end if word had one match
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of form `x=expression`
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
#setopt correct_all        # autocorrect commands

# ZSH files cleanup
export ZSH_CACHE="$HOME/.cache/zsh"
export ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-$ZSH_VERSION" # for auto/tab completion

[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful # Ubuntu makes this every with sudo usage

# History configuration
HISTFILE="$ZSH_CACHE/history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory # save history entries as soon as they are entered
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

# Environmental variable exports, including XDG standard definitions
[ -f ~/.config/sh/environ ] && source ~/.config/sh/environ
# Setup aliases
[ -f ~/.config/sh/aliases ] && source ~/.config/sh/aliases
# Load handlers
[ -f ~/.config/sh/handlers ] && source ~/.config/sh/handlers
# Load key bindings
[ -f ~/.config/sh/keybinds ] && source ~/.config/sh/keybinds
# Load prompt
[ -f ~/.config/sh/theme ] && . ~/.config/sh/theme

# Load extensions (should be last)
. /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null     # Syntax highlighting
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null # Auto suggestions
. /usr/share/autojump/autojump.zsh 2>/dev/null                                   # Auto-Jump

# Syntax highlighting features
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
    ZSH_HIGHLIGHT_STYLES[default]=none
    ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
    ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
    ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[path]=underline
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[command-substitution]=none
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[process-substitution]=none
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[assign]=none
    ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
    ZSH_HIGHLIGHT_STYLES[named-fd]=none
    ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
    ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
    ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
    ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
    ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
fi
