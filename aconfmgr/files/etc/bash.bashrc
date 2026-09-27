#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prevent doublesourcing
if [[ -z "${BASHRCSOURCED}" ]] ; then
  BASHRCSOURCED="Y"
  # the check is bash's default value
  [[ "$PS1" = '\s-\v\$ ' ]] && PS1='[\u@\h \W]\$ '
  case ${TERM} in
    Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
      PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
    screen*)
      PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
  esac
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# Load environment.d using systemd's own parser.
#
# This reads the environment.d configuration from the standard locations:
# - ~/.config/environment.d/*.conf
# - /etc/environment.d/*.conf
# - /run/environment.d/*.conf
# - /usr/local/lib/environment.d/*.conf
# - /usr/lib/environment.d/*.conf
# - /etc/environment
#
# Files with the same name shadow lower-priority copies, while the resulting
# set of files is processed in alphabetic filename order.
#
# I prefer using environment.d definitions for most of my non-bash specific env
# vars, as they're shell agnostic, and they get automatically loaded up by
# systemd user units.
#
# However, Bash itself doensn't load environment.d, so importing it here makes
# the same declared environment vars available even when Bash is started
# outside of a systemd-user-managed graphical session, such as from a TTY or
# via su.
#
# This will not necessarily reproduce the active systemd user-manager
# environment. It only evaluates systemd's environment.d generator. Other
# environment generators and manual runtime changes, like those made with:
# `systemctl --user import-environment` are intentionally not included.
_load_environment_d() {
    local name value

    while IFS='=' read -r name value; do
        [[ -n $name ]] && export "$name=$value"
    done < <(
        /usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator
    )
}

_load_environment_d
unset -f _load_environment_d
