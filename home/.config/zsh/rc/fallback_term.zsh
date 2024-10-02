# If the set $TERM variable doesn't match any configured terminfo entries
# fall back to xterm. This fixes SSH connections from unknown terminals

if ! infocmp "$TERM" &>/dev/null; then
  echo "Setting \$TERM to xterm-256color due to missing terminfo entry for $TERM."
  export TERM=xterm-256color
fi

