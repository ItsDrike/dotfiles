#!/usr/bin/env zsh
# shellcheck disable=SC2155

###############################################################################
# Configuration variables
###############################################################################

# Once we are too deep in the filestructure, we can usually afford to shorten
# the whole working directory and only print something like ~/.../dir3/dir4/dir5
# instead of ~/dir1/dir2/dir3/dir4/dir5. If this isn't desired, set this to 0.
USE_SHORTENED_WORKDIR=1

# Show how much time it took to run a command
CMD_TIME_SHOW=1

# Minimum units to show the time precision.
# If the duration reports 0 for the selected unit, no output will be printed.
# Valid options: ms/s/m/h/d
CMD_TIME_PRECISION="s"

# Minimum time in milliseconds before displaying command duration.
# This is especially useful if your time precision unit is small and you don't
# want to see duration of very short commands, such as `cat`.
# Setting this to 0 will always print the time taken
CMD_TIME_MINIMUM=100

# Set the EOL sign
PROMPT_EOL_MARK="%"

# Select a prompt color palette based on the capabilities advertised by the
# current terminal's terminfo entry.
#
# `tput colors` reports how many colors applications should assume are
# available for the current $TERM. If the query fails or reports no color
# support, disable prompt colors entirely. Terminals with fewer than 256 colors
# use a basic ANSI palette, while 256-color capable terminals use a richer
# palette.
colors="$(tput colors 2>/dev/null)"

if [[ -z "$colors" || $colors -le 0 ]]; then
    GREEN=""
    RED=""
    BRIGHT_RED=""
    ORANGE=""
    GRAY=""
    BLUE=""
    LBLUE=""
    PURPLE=""
    RESET=""
elif (( colors < 256 )); then
    GREEN="%F{2}"
    RED="%F{1}"
    BRIGHT_RED="%F{9}"
    ORANGE="%F{3}"
    GRAY="%F{7}"
    BLUE="%F{4}"
    LBLUE="%F{12}"
    PURPLE="%F{5}"
    RESET="%f"
else
    GREEN="%F{2}"
    RED="%F{1}"
    BRIGHT_RED="%F{9}"
    ORANGE="%F{214}"
    GRAY="%F{248}"
    BLUE="%F{27}"
    LBLUE="%F{75}"
    PURPLE="%F{105}"
    RESET="%f"
fi

unset colors

# Determine whether it is reasonable to use Unicode characters in the prompt.
#
# Terminal descriptions do not reliably advertise Unicode support, so use the
# active locale's character encoding as a practical approximation. Fall back to
# ASCII when the locale is not UTF-8.
#
# On top of the locale config check, we also special-case the Linux virtual
# console (TTY), where glyph availability depends on the loaded console font
# and cannot be determined reliably from the shell.
if [[ "$TERM" != "linux" && $(locale charmap 2>/dev/null) == UTF-8 ]]; then
    PROMPT_UNICODE=1
else
    PROMPT_UNICODE=0
fi

###############################################################################
# Prompt functionality (hooks, helper functions)
###############################################################################

# Signals git status of CWD repository, if any
git_prompt() {
    local ref

    ref=$(command git symbolic-ref HEAD 2> /dev/null) \
        || ref=$(command git rev-parse --short HEAD 2> /dev/null) \
        || return 0

    print -n " ${ORANGE}${ref#refs/heads/}"

    if [[ -n "$(git status --short 2>/dev/null)" ]]; then
        print -n "${BRIGHT_RED}+"
    fi
}

# Add @chroot or @ssh.
#
# Chroot takes precedence over SSH.
foreign_prompt() {
    if [[ "$(awk '$5=="/" {print $1}' </proc/1/mountinfo)" != "$(awk '$5=="/" {print $1}' </proc/$$/mountinfo)" ]]; then
        print -n "${GRAY}@${ORANGE}chroot"
    elif [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]]; then
        print -n "${GRAY}@${ORANGE}ssh"
    fi
}

# Prints the current working directory
working_directory() {
    # By default up to 5 directories will be tolerated before shortening.
    # After we surpass that, the first directory (or ~) is printed together
    # with the last 3, separated by a unicode ellipsis symbol ('…').
    #
    # The Unicode ellipsis is avoided on the Linux virtual console (TTY),
    # so we fall back to '...' there.
    if [ $USE_SHORTENED_WORKDIR != 1 ]; then
        print -n " ${BLUE}%~"
    elif (( PROMPT_UNICODE )); then
        print -n " ${BLUE}%(5~|%-1~/…/%3~|%4~)"
    else
        print -n " ${BLUE}%(5~|%-1~/.../%3~|%4~)"
    fi
}

# Execution time tracking hook (preexec).
#
# Stores the start time, at which the command was sent.
exec_time_preexec_hook() {
    [[ $CMD_TIME_SHOW == 0 ]] && return
    PROMPT_EXEC_TIME_START=$(date +%s.%N)
}

# Execution time tracking hook (precmd).
#
# Stores the end time, at which the command was completed, and computes the
# total duration (in miliseconds).
exec_time_precmd_hook() {
    [[ $CMD_TIME_SHOW == 0 ]] && return
    [[ -z $PROMPT_EXEC_TIME_START ]] && return

    local PROMPT_EXEC_TIME_STOP="$(date +%s.%N)"

    PROMPT_EXEC_TIME_DURATION=$(
        printf '%.0f' \
	  "$(( (PROMPT_EXEC_TIME_STOP - PROMPT_EXEC_TIME_START) * 1000 ))"
    )


    unset PROMPT_EXEC_TIME_START
}

# Format a millisecond duration into something such as "2m 12s".
#
# $1: millisecond amount, integer or float
# $2: precision, one of ms/s/m/h/d
format_time() {
    local -i T="$1"
    local -i D=$(( T / 1000 / 60 / 60 / 24 ))
    local -i H=$(( T / 1000 / 60 / 60 % 24 ))
    local -i M=$(( T / 1000 / 60 % 60 ))
    local -i S=$(( T / 1000 % 60 ))
    local -i MS=$(( T % 1000 ))

    local precision=$2
    local out=""
    case "$precision" in
        "ms") (( MS > 0 )) && out="${MS}ms ${out}"; precision="s" ;&
        "s")  (( S > 0 ))  && out="${S}s ${out}";   precision="m" ;&
        "m")  (( M > 0 ))  && out="${M}m ${out}";   precision="h" ;&
        "h")  (( H > 0 ))  && out="${H}h ${out}";   precision="d" ;&
        "d")  (( D > 0 ))  && out="${D}d ${out}" ;; 
        *) out="$T" ;; # Return $1 ($T) if precision wasn't specified/valid
    esac

    print -nr -- "$out"
}

display_cmd_time() {
    [[ $CMD_TIME_SHOW == 0 ]] && return
    [[ -z $PROMPT_EXEC_TIME_DURATION ]] && return

    # If the time duration is less than minimum time, quit early
    if (( PROMPT_EXEC_TIME_DURATION < CMD_TIME_MINIMUM )); then
        return
    fi

    local time_took="$(format_time "$PROMPT_EXEC_TIME_DURATION" "$CMD_TIME_PRECISION")"

    # If format_time output was empty, quit early.
    # This happens when all fields down to selected precisions were 0.
    [[ -z "$time_took" ]] && return

    print -n " ${LBLUE}took ${time_took}"
}

###############################################################################
# Prompt definition
###############################################################################

setopt promptsubst  # enable command substitution in prompt

# Setup ZSH hooks to display the running time of commands
autoload -Uz add-zsh-hook
add-zsh-hook preexec exec_time_preexec_hook
add-zsh-hook precmd exec_time_precmd_hook

# Primary Prompt
[ "$EUID" -eq 0 ] && PS1="${RED}%n${RESET}" || PS1="${GREEN}%n${RESET}" # user
PS1+="$(foreign_prompt)"
PS1+="$(working_directory)"
PS1+="\$(git_prompt)"
PS1+="\$(display_cmd_time)"
PS1+=" ${PURPLE}%(!.#.$)${RESET} " # Final symbol (# or $)

# Continuation prompt.
PS2="${RED}\ ${RESET}"

# Right side prompt
RPS1=""
if (( PROMPT_UNICODE )); then
    RPS1+="%(?..${RED}%? X$RESET)"
else
    # NOTE: "↵" symbol could cause issues with on some terminals/machines that
    # don't handle unicode well, this issue could be very confusing to debug,
    # and it would not be apparent what's wrong since the symbol itself will
    # be drawn, however when it is drawn, it will also move the cursor line
    # 2 places back since this symbol is made up of 3 bytes (in unicode) and
    # regular ASCII characters only take up 1 byte, this means that whenever
    # the right-side prompt appears (on error), the prompt would have this issue.
    RPS1="%(?..${RED}%? ↵$RESET)"
fi
