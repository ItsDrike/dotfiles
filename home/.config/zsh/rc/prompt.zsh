#!/usr/bin/env zsh
# shellcheck disable=SC2155

# Configuration variables:

# Once we are too deep in the filestructure, we can usually afford to shorten
# the whole working directory and only print something like ~/.../dir3/dir4/dir5
# instead of ~/dir1/dir2/dir3/dir4/dir5. If this isn't desired, set this to 0
USE_SHORTENED_WORKDIR=1

# Show how much time it took to run a command
CMD_TIME_SHOW=1
# Minimum units to show the time precision, if
# we use "s" (seconds), and the output took 0s,
# we don't print the output at all to avoid clutter.
# Same goes for any other units, however with "ms"
# (miliseconds), this is very unlikely
# Valid options: ms/s/m/h/d
CMD_TIME_PRECISION="s"
# Minimum time in miliseconds, to print the time took,
# if the command takes less than this amount of miliseconds,
# don't bother printing the time took, this is nice if you
# don't need to see how long commands like 'echo' took
# Setting this to 0 will always print the time taken
CMD_TIME_MINIMUM=100

# hide EOL sign ('%')
export PROMPT_EOL_MARK=""

# TTY (pure linux) terminal only has 8-bit color support
# (unless you change it in kernel), respect this and downgrade
# the color scheme accordingly (it won't look best, but it's
# still better than no colors)
if [ "$TERM" = "linux" ]; then
    GREEN="%F{002}"
    RED="%F{001}"
    ORANGE="%F{003}"
    BLUE="%F{004}"
    LBLUE="%F{006}"
    PURPLE="%F{005}"
else
    GREEN="%F{047}"
    RED="%F{196}"
    ORANGE="%F{214}"
    BLUE="%F{027}"
    LBLUE="%F{075}"
    PURPLE="%F{105}"
fi
RESET="%f"

# Signals git status of CWD repository (if any)
git_prompt() {
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo -n " $ORANGE${ref#refs/heads/}"

    if [ -n "$(git status --short 2>/dev/null)" ]; then
        echo "$RED+"
    fi
}

# Adds @chroot or @ssh
foreign_prompt() {
    if [ "$(awk '$5=="/" {print $1}' </proc/1/mountinfo)" != "$(awk '$5=="/" {print $1}' </proc/$$/mountinfo)" ]; then
        echo -n "@${ORANGE}chroot"
    elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo -n "@${ORANGE}ssh"
    fi
}

#nd Prints appropriate working directory
working_directory() {
    # By default up to 5 directories will be tolerated before shortening
    # After we surpass that, first directory (or ~) will be printed together with last 3
    # This feature uses special symbol '…', but this isn't aviable when in TTY. Because
    # of this, when we are in TTY, we fall back to longer '...'

    if [ $USE_SHORTENED_WORKDIR != 1 ]; then
        echo -n " $BLUE$~"
    elif [ "$TERM" = "linux" ]; then
        echo -n " $BLUE%(5~|%-1~/.../%3~|%4~)"
    else
        echo -n " $BLUE%(5~|%-1~/…/%3~|%4~)"
    fi
}

# Execution time tracking hooks, this is unique to zsh, as it can add
# preexec and precmd hooks. We can utilize this to keep track of the
# amount of time it took to run certain command. We store the start time
# within a variable: PROMPT_EXEC_TIME_START, which we then compare and
# unset after the command was finished. In here, we simply set the
# PROMPT_EXEC_TIME_DURATION, which is then used in the actual prompt
# This will only be enabled if SHOW_CMD_TIME is 1.
exec_time_preexec_hook() {
    [[ $SHOW_CMD_TIME == 0 ]] && return
    PROMPT_EXEC_TIME_START=$(date +%s.%N)
}
exec_time_precmd_hook() {
    [[ $SHOW_CMD_TIME == 0 ]] && return
    [[ -z $PROMPT_EXEC_TIME_START ]] && return
    local PROMPT_EXEC_TIME_STOP="$(date +%s.%N)"
    PROMPT_EXEC_TIME_DURATION=$(echo "($PROMPT_EXEC_TIME_STOP - $PROMPT_EXEC_TIME_START) * 1000" | bc -l)
    unset PROMPT_EXEC_TIME_START
}
format_time() {
    # Do some formatting to get nice time (e.g. 2m 12s) from miliseconds
    # $1 is the milisecond amount (int or float)
    # $2 is the precision (ms/s/m/h/d)
    local T="$1"
    local D="$(echo "scale=0;$T/1000/60/60/24" | bc -l)"
    local H="$(echo "scale=0;$T/1000/60/60%24" | bc -l)"
    local M="$(echo "scale=0;$T/1000/60%60" | bc -l)"
    local S="$(echo "scale=0;$T/1000%60" | bc -l)"
    local MS="$(echo "scale=0;$T%1000" | bc -l)"

    local precision=$2
    local out=""
    case "$precision" in
        "ms") [[ "$MS" -gt 0 ]] && out="$(printf "%dms" "$MS") ${out}"; precision="s" ;&
        "s") [[ "$S" -gt 0 ]] && out="$(printf "%ds" "$S") ${out}"; precision="m" ;&
        "m") [[ "$M" -gt 0 ]] && out="$(printf "%dm" "$M") ${out}"; precision="h" ;&
        "h") [[ "$H" -gt 0 ]] && out="$(printf "%dh" "$H") ${out}"; precision="d" ;&
        "d") [[ "$D" -gt 0 ]] && out="$(printf "%dd" "$D") ${out}" ;;
        *) out="$T" ;; # Return $1 ($T) if precision wasn't specified/valid
    esac
    printf "%s" "$out"
}
display_cmd_time() {
    [[ $CMD_TIME_SHOW == 0 ]] && return
    [[ -z $PROMPT_EXEC_TIME_DURATION ]] && return
    # If the time duration is less than minimum time,
    # don't print the time taken
    [[ $PROMPT_EXEC_TIME_DURATION -lt $CMD_TIME_MINIMUM ]] && return
    local time_took="$(format_time "$PROMPT_EXEC_TIME_DURATION" "$CMD_TIME_PRECISION")"
    # Don't display if the time didn't give us output
    # this happens when all fields (seconds/minutes/...) are 0,
    # if we use milisecond precision, this will likely never happen
    # but with other precisions, it could
    [ ${#time_took} -eq 0 ] && return
    echo -n " ${LBLUE}took ${time_took}"
}

setopt promptsubst  # enable command substitution in prompt

# Setup ZSH hooks to display the running time of commands
autoload -Uz add-zsh-hook
add-zsh-hook preexec exec_time_preexec_hook
add-zsh-hook precmd exec_time_precmd_hook

# Primary Prompt
[ "$EUID" -eq 0 ] && PS1="$RED%n$RESET" || PS1="$GREEN%n$RESET" # user
PS1+="$(foreign_prompt)"
PS1+="$(working_directory)"
PS1+="\$(git_prompt)"
PS1+="\$(display_cmd_time)"
PS1+=" $PURPLE%(!.#.$)$RESET " # Final symbol (# or $)

# Next line prompt
PS2="$RED\ $RESET"

# Right side prompt
RPS1=""
if [ "$TERM" = "linux" ]; then
    # Displaying cmd time here works, but often causes issues when we
    # resize the terminal, since right prompts can be annoying to deal
    # with when resizing. This would run relatively often so it makes
    # more sense to only use it in PS1 (left prompt), but if desired,
    # this can be uncommented
    #RPS1+="\$(display_cmd_time)"

    # If we find a non-zero return code, print it in the right prompt,
    # use X here, to avoid issues with TTY not having support for
    # a nicer unicode character that we use otherwise ("↵")
    RPS1+="%(?..${RED}%? X$RESET)"
else
    # Read comments for the section above.
    #RPS1+="\$(display_cmd_time)"

    # NOTE: "↵" symbol could cause issues with on some terminals/machines that
    # don't handle unicode well, this issue could be very confusing to debug,
    # and it would not be apparent what's wrong since the symbol itself will
    # be drawn, however when it is drawn, it will also move the cursor line
    # 2 places back since this symbol is made up of 3 bytes (in unicode) and
    # regular ASCII characters only take up 1 byte, this means that whenever
    # the right-side prompt appears (on error), the prompt would have this issue.
    RPS1="%(?..${RED}%? ↵$RESET)"
fi


