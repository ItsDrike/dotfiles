# Rootless Podman for local development. Unlike Docker, Podman does not require
# a daemon or privileged group membership; containers run in the invoking
# user's namespace.
AddPackage podman

# Podman can run in rootful mode too, when it's invoked by the root account, in
# that case, podman has rootful container storage/state, which we don't want to
# manage. Rootless state lives in the user's home directory, outside of
# aconfmgr's scope (doesn't need ignoring).
IgnorePath '/var/lib/containers'
