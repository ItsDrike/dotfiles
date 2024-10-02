export HISTSIZE=12000
export SAVEHIST=10000

# Append history list to history file once the session exits, rather than replacing
# the history file, erasing any past entries
setopt APPEND_HISTORY

# If the internal history needs to be trimmed to add the current command line, setting this
# option will cause the oldest history event that has a duplicate to be lost before losing a
# unique event from the list. You should be sure to set the value of HISTSIZE to a larger
# number than SAVEHIST in order to give you some room for the duplicated events, otherwise
# this option will behave just like HIST_IGNORE_ALL_DUPS once the history fills up with unique
# events.
setopt HIST_EXPIRE_DUPS_FIRST

# When searching for history entries in the line editor, do not display duplicates of a line
# previously found, even if the duplicates are not contiguous.
setopt HIST_FIND_NO_DUPS

# If a new command line being added to the history list duplicates an older one, the older
# command is removed from the list (even if it is not the previous event).
setopt HIST_IGNORE_ALL_DUPS

# Remove command lines from the history list when the first character on the line is a space,
# or when one of the expanded aliases contains a leading space. Only normal aliases (not
# global or suffix aliases) have this behaviour. Note that the command lingers in the internal
# history until the next command is entered before it vanishes, allowing you to briefly reuse
# or edit the line. If you want to make it vanish right away without entering another command,
# type a space and press return.
setopt HIST_IGNORE_SPACE

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt HIST_SAVE_NO_DUPS

# This option works like APPEND_HISTORY except that new history lines are added to the $HISTFILE
# incrementally (as soon as they are entered), rather than waiting until the shell exits.
setopt INC_APPEND_HISTORY

# When using history expansion (such as with sudo !!), on enter, first show the expanded command
# and only run it after confirmation (another enter press)
setopt HIST_VERIFY

# Remove superfluous blanks from each command line being added to the history list
setopt HIST_REDUCE_BLANKS

# When writing out the history file, by default zsh uses ad-hoc file locking to avoid known
# problems with locking on some operating systems. With this option, locking is done by means
# of the `fcntl` system call, where this method is available. This can improve performance on
# recent operating systems, and is better at avoiding history corruption when files are stored
# on NFS.
setopt HIST_FCNTL_LOCK

# Save each command's beginning time (unix timestamp) and the duration (in seconds) to the
# history file.
setopt EXTENDED_HISTORY

# beep in ZLE when a widget attempts to access a history entry which isn’t there
unsetopt HIST_BEEP

