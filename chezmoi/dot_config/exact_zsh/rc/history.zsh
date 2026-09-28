###############################################################################
# Configure ZSH's command history behavior.
###############################################################################

# ZSH keeps an in-memory history for the current shell and can persist that
# history into HISTFILE so it remains available across shell sessions.
#
# HISTSIZE controls how many history entries ZSH keeps in memory, while
# SAVEHIST controls how mnay entries are retained in HISTFILE.
#
# The history file is stored under XDG_STATE_HOME, as command history is
# persistent mutable state rather than configuration or cache data.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=12000
SAVEHIST=10000

mkdir -p "${HISTFILE:h}"

# If a new command duplicates an older history entry, remove the older entry
# from the in-memory history rather than retaining both copies.
setopt HIST_IGNORE_ALL_DUPS

# When searching through history in ZLE, don't display duplicate entries taht
# have already been encountered during the same search.
setopt HIST_FIND_NO_DUPS

# Don't save commands whose first character is a space.
#
# This also applies when a normal alias expands to a command beginning with a
# space. The command remains temporarily available in the current shell
# in-memory history, until another command is entered, after which it is
# removed from that history and lost.
setopt HIST_IGNORE_SPACE

# When writing the history file, omit older entries that duplicate newer ones.
#
# This complements HIST_IGNORE_ALL_DUPS by also applying deduplication when
# history is persisted to disk.
setopt HIST_SAVE_NO_DUPS

# Write each history entry to HISTFILE once the command finishes instead of
# waiting until the shell exits.
#
# Unlike INC_APPEND_HISTORY, this delays the write until command completion so
# EXTENDED_HISTORY can also record the command's actual execution duration.
setopt INC_APPEND_HISTORY_TIME

# Store each command's start time and execution duration in HISTFILE in addition
# to the command itself.
setopt EXTENDED_HISTORY

# When history expansion is used, such as with `sudo !!`, show the expanded
# command in the command line first instead of executing it immediately.
#
# The expanded command is only executed after pressing enter again.
setopt HIST_VERIFY

# Remove unnecessary whitespace from commands before adding them to history.
setopt HIST_REDUCE_BLANKS

# Use fcntl-based locking for HISTFILE where supported.
#
# This provides more robust locking between multiple ZSH processes via the
# `fcntl` syscall (when available) rather than ZSH's fallback ad-hoc file
# locking mechanism.
#
# This can improve performance on recent operating systems, and is better at
# avoiding history corruption when files are stored on network-backed
# filesystems (eg NFS).
setopt HIST_FCNTL_LOCK

# Don't beep when a ZLE widget attempts to access a history entry that doesn't
# exist.
#
# I don't know who thought beeping on anything was a good idea. Just no.
unsetopt HIST_BEEP
