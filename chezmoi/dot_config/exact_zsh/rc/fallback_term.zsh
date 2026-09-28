# Fall back to a widely supported terminal type when the terminal advertised by
# the client is not available in the local terminfo database.
#
# SSH forwards the client's TERM value to the remote session, but the remote
# system (this system) might not have the corresponding terminfo entry
# installed. Using an unknown terminal type can cause broken key handling,
# colors, and other TUI behavior.
if ! infocmp "$TERM" &>/dev/null; then
  if infocmp xterm-256color &>/dev/null; then
    print -ru2 -- "Setting \$TERM to xterm-256color due to missing terminfo entry for $TERM."
    export TERM=xterm-256color
  else
    print -ru2 -- "Setting \$TERM to xterm due to missing terminfo entry for $TERM."
    export TERM=xterm
  fi
elif [[ "$TERM" == xterm ]] && infocmp xterm-256color &>/dev/null; then
  print -ru2 -- "Upgrading \$TERM from xterm to xterm-256color."
  export TERM=xterm-256color
fi

