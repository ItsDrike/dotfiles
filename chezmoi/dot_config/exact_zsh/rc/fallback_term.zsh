# Fall back to a widely supported terminal type when the terminal advertised by
# the client is not available in the local terminfo database.
#
# SSH forwards the client's TERM value to the remote session, but the remote
# system (this system) might not have the corresponding terminfo entry
# installed. Using an unknown terminal type can cause broken key handling,
# colors, and other TUI behavior.
#
# This logic will only run for an interactive shell attached to a terminal.
# We don't want to alter TERM for commands, scripts or automation.
if [[ -o interactive && -t 0 && -t 1 ]]; then
  # If the TERM entry points to an unknown terminfo, or is TERM=dumb
  # (which basically has no support for proper interactive behavior)
  # run the fallback handling.
  if [[ "$TERM" == dumb ]] || ! infocmp "$TERM" &>/dev/null; then
    if infocmp xterm-256color &>/dev/null; then
      print -ru2 -- "Setting \$TERM to xterm-256color due to unusable terminal type: ${TERM:-\<unset\>}."
      export TERM=xterm-256color
    elif infocmp xterm &>/dev/null; then
      print -ru2 -- "Setting \$TERM to xterm due to unusable terminal type: ${TERM:-\<unset\>}."
      export TERM=xterm
    fi
  # For TERM=xterm, most things should work fine, but if there is support for
  # it, we should attempt to upgrade to the variant with 256 color support.
  elif [[ "$TERM" == xterm ]] && infocmp xterm-256color &>/dev/null; then
    print -ru2 -- "Upgrading \$TERM from xterm to xterm-256color."
    export TERM=xterm-256color
  fi
fi

