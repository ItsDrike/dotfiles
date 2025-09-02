#!/usr/bin/zsh

source ~/.config/zsh/rc/fallback_term.zsh
source ~/.config/zsh/rc/history.zsh
source ~/.config/zsh/rc/opts.zsh
source ~/.config/zsh/rc/completion.zsh
source ~/.config/zsh/rc/keybinds.zsh
source ~/.config/zsh/rc/prompt.zsh
source ~/.config/zsh/rc/cmd_not_found.zsh
source ~/.config/zsh/rc/auto_cleanup.zsh

# Setup aliases
[ -f ~/.config/shell/aliases ] && source ~/.config/shell/aliases

source ~/.config/zsh/rc/misc.zsh
source ~/.config/zsh/rc/plugins.zsh
source ~/.config/zsh/rc/zgenom.zsh
