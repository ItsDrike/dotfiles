# Set automatic timeout for shell
# which will automatically log out the user after certain amount of time
# This will not work on termunal emulators in X11
TMOUT="$(( 60*10 ))";
[ -z "$DISPLAY" ] && export TMOUT;
case $( /usr/bin/tty ) in
	/dev/tty[0-9]*) export TMOUT;;
esac
