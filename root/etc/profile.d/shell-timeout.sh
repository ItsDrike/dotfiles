# Set automatic timeout for shell
# which will automatically log out the user after certain amount of time

# This will only be applied for non-graphical sessions,
# or whenever root account is logged in

TMOUT=600
readonly TMOUT

[ -z "$DISPLAY" ] && export TMOUT;

case $(/usr/bin/tty) in
	/dev/tty[0-9]*) export TMOUT;;
esac

[ $UID -eq 0 ] && export TMOUT;
