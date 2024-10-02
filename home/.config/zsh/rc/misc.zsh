# This file contains miscellaneous configurations,
# usually required by external applications that isn't suited for plugins.zsh
# or just general ZSH/shell settings that don't fit anywhere else

# Foot terminal uses this sequence to identify a command execution
# that way it's possible to use ctrl+shift+z/x to jump between commands
if [ "$TERM" = "foot" ]; then
    precmd() {
        print -Pn "\e]133;A\e\\"
    }
fi

# Define TMOUT timeout for TTY and root
# [ -z "$DISPLAY" ] && export TMOUT=800
# [ $UID -eq 0 ] && export TMOUT=600
