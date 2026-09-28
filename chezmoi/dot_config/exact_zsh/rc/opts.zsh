# Set or unset various zsh options.
# You can read more about what options are available and what these do in
# the ZSH manual: <https://zsh.sourceforge.io/Doc/Release/Options.html>
#
# Note that this file focuses on global, otherwise uncategorized options:
# * history-related options are set from history.zsh,
# * completion-related options are set from completion.zsh

###############################################################################
# General options
###############################################################################

setopt AUTO_CD              # Treat a directory name entered as a command as `cd <directory>`.
setopt INTERACTIVE_COMMENTS # Allow `#` comments in interactive command lines.
setopt MAGIC_EQUAL_SUBST    # Perform filename expansion after `=` in arguments such as `foo=~/path`.
setopt NOTIFY               # Report background-job status changes immediately instead of waiting for the next prompt.
setopt NUMERIC_GLOB_SORT    # Sort numeric portions of glob matches numerically rather than lexicographically.
setopt GLOB_DOTS            # Allow `*` and other glob patterns to match dotfiles without explicitly writing `.*`.

###############################################################################
# Directory stack
###############################################################################

setopt AUTO_PUSHD           # Make `cd` push the previous directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS    # Avoid duplicate entries in the directory stack.
setopt PUSHD_TO_HOME        # Make `pushd` with no arguments behave like `pushd "$HOME"`.
setopt PUSHD_SILENT         # Do not print the directory stack after `pushd`/`popd`.
