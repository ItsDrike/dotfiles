# Set automatic timeout for shell
# which will automatically log out the user after certain amount of time

# This will only be applied for non-graphical sessions,
# or whenever root account is logged in

# If TMOUT was already set, unset it
unset TMOUT

# Define the timeout delay (seconds)
TIMEOUT=600

# Set TMOUT when display is not set
[ -z "$DISPLAY" ] && export TMOUT=$TIMEOUT;

# Set TMOUT when in TTY
case $(/usr/bin/tty) in
	/dev/tty[0-9]*) export TMOUT=$TIMEOUT;;
esac

# Set TMOUT when user is root
[ $UID -eq 0 ] && export TMOUT=$TIMEOUT;

