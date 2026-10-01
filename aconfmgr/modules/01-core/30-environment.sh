# System-wide environment variables inherited by user sessions and services.

# Set the globally preferred $EDITOR to nvim
#
# (This is the only correct choice, people using the default vi are crazy, vim
# is meh, people using nano or other things should be burned.)
CopyFile /etc/environment.d/10-editor.conf
