# Set or unset various zsh options.
# You can read more about what options are available and what these do in
# the ZSH manual: <https://zsh.sourceforge.io/Doc/Release/Options.html>
#
# Note that history-related options are set from history.zsh, not from here.

#########################
# General/Other options #
#########################

setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt AUTO_LIST            # automatically list choices on ambiguous completion
setopt AUTO_MENU            # automatically use menu completion
setopt MENU_COMPLETE        # insert first match immediately on ambiguous completion
setopt AUTO_PARAM_SLASH     # if a parameter is completed with a directory, add trailing slash instead of space
setopt ALWAYS_TO_END        # move cursor to end if word had one match
setopt INTERACTIVE_COMMENTS # allow comments in interactive mode
setopt MAGIC_EQUAL_SUBST    # enable filename expansion for arguments of form `x=expression`
setopt NOTIFY               # report the status of background jobs immediately
setopt NUMERIC_GLOB_SORT    # sort filenames numerically when it makes sense
setopt GLOB_DOTS            # Match files starting with . without specifying it (cd <TAB>)


######################
# Auto pushd options #
######################

setopt AUTO_PUSHD           # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS    # don't push multiple copies of the same directory
setopt PUSHD_TO_HOME        # have pushd with no arguments act like `pushd $HOME`
setopt PUSHD_SILENT         # do not print the directory stack
