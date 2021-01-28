# ZSH files cleanup
export ZSH_CACHE="$HOME/.cache/zsh"
export ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-$ZSH_VERSION" # for auto/tab completion

[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful # Ubuntu makes this every with sudo usage

# History configuration
HISTFILE="$ZSH_CACHE/history"
HISTSIZE=10000
SAVEHIST=10000

# oh-my-zsh configuration
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="af-magic"
UPDATE_ZSH_DAYS=5
ENABLE_CORRECTION="false"
source $ZSH/oh-my-zsh.sh # Run oh-my-zsh

# Basic auto/tab complete
autoload -Uz compinit
zmodload -i zsh/complist
compinit -d $ZSH_COMPDUMP
comp_options+=(globdots)

# ZSH Options
setopt appendhistory # save history entries as soon as they are entered
#setopt share_history # share history between different instances of the shell
setopt auto_cd # cd by typing directory name if it's not a command
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
#setopt correct_all # autocorrect commands

zstyle ':completion:*' menu select # # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completio

autoload -U colors && colors # enable color support

# Environmental variable exports, including XDG standard definitions
[ -f ~/.config/sh/environ ] && source ~/.config/sh/environ
# Setup aliases
[ -f ~/.config/sh/aliases ] && source ~/.config/sh/aliases
# Load handlers
[ -f ~/.config/sh/handlers ] && source ~/.config/sh/handlers
# Load key bindings
[ -f ~/.config/sh/keybinds ] && source ~/.config/sh/keybinds


# Load extensions (should be last)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null  # Syntax highlighting
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null  # Auto suggestions
source /usr/share/autojump/autojump.zsh 2>/dev/null  # Auto-Jump

