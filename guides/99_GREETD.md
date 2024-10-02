# Greetd

This guide goes over how to setup `greetd`, which is a minimalistic Display
Manager (DM) that starts right after boot and asks the user to log in.

A DM is useful for letting you pick which session you wish to load after
logging in (e.g. which WM/DE), but also to provide a slightly nicer UI in
comparison to the default `agetty` TTY based login screen.

Another neat feature that greetd offers is automatic login, which will allow
you to skip the login process entirely, logging you in right after the boot.
This can be useful if you're already typing in your LUKS encryption password
each time after a boot, which already acts as a sufficient layer of protection
against attackers trying to enter your system.

<!-- markdownlint-disable MD028 -->

> [!WARNING]
> If you've set up TPM unlocking for your LUKS encryption, setting up automatic
> login is not safe, unless you're using a TPM passphrase/PIN.

> [!IMPORTANT]
> If you're following while using my dotfiles, you will need to manually place
> the greetd config from the repo into `/etc/greed/config.toml`. The
> installation scripts don't do this, as many people prefer not using a
> greeter.
>
> You will also need to follow the installation instructions to download greetd
> and enable it.

<!-- markdownlint-enable MD028 -->

## Greetd + tuigreet

Since I prefer a minimalistic approach to most things in my system, I like to
use a terminal based greeter. Greetd itself is just a daemon that supports
various greeters. Most of these greeters are graphical, but there are terminal
based ones too, most notably `tuigreet`, which works right from the TTY.

First, install and enable greetd, to make sure it gets started on boot.

```bash
sudo pacman -S greetd greetd-tuigreet
sudo systemctl enable greetd
```

Now, we will want to define our greetd configuration in
`/etc/greetd/config.toml`. There should already be a default configuraion that
uses `agreety` greeter, which is similar to `agetty`, we'll want to change that
to `tuigreet`, which in my opinion looks a lot better. We can use the following
config:

<!-- markdownlint-disable MD013 -->

```toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]

command = "tuigreet --time --remember --remember-user-session --asterisks --greeting 'Stop staring and log in already' --theme 'border=magenta;text=cyan;prompt=green;time=red;action=white;button=yellow;container=black;input=gray' --sessions /usr/share/wayland-sessions --xsessions /usr/share/xsessions --session-wrapper /usr/local/bin/greetd-session-wrapper --xsession-wrapper /usr/local/bin/greetd-session-wrapper startx /usr/bin/env"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"
```

<!-- markdownlint-enable MD013 -->

> [!NOTE]
> I know the `tuigreet` command is really hard to orient in when written in a
> single line like this, however, attempting to use a multi-line string doesn't
> seem to work with greetd (even though it is a part of the TOML standard).
> This issue has already been
> [reported](https://lists.sr.ht/~kennylevinsen/greetd/<trinity-082b25fc-e1fa-4772-950c-d458f065024a-1648717080362@3c-app-mailcom-bs08>),
> yet it doesn't seem like it was addressed.

You may have noticed that I've referred to a
`/usr/local/bin/greetd-session-wrapper` script here, that's a custom script that
I wrote to get greetd to run the command to start the WM/DE session within a
running user shell (bash/zsh), so that the appropriate environment variables
will be set when the WM is launched.

This is the content of that script:

```bash
#!/bin/bash
set -euo pipefail

# This is a helper wrapper script for greetd.
#
# It will run the session / application using the appropriate shell configured for
# this user. That way, we can make sure all of the environment variables are set
# before the WM/DE session is started.
#
# This is very important, as without it, variables for things like qt theme
# will not be set, and applications executed by the WM/DE will not be themed properly.

script_name="$0"
shell="$(getent passwd "$USER" | awk -F: '{print $NF}')"
command=("$@")

exec "$shell" -c 'exec "$@"' "$script_name" "${command[@]}"
```

With this configuration, you can now reboot and check whether greetd works
properly. (You will still be asked for a password.)

```bash
reboot
```

If everything worked properly, you should've been presented with a custom
tuigreet login screen after booting.

> [!TIP]
> Feel free to adjust the `tuigreet` settings to your liking by editing the
> `command` in the greetd settings. If you need a reference for what settings
> are available, you can check out the
> [`tuigreet`](https://github.com/apognu/tuigreet) project page.

## Configuring automatic Login

To configure automatic login, we'll need to modify the `greetd` settings in
`/etc/greetd/config.toml` and add an initial session section:

```toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# Auto-login session, triggered right after boot.
# If the user logs out, greetd will render the default session
[initial_session]
user = "itsdrike"  # TODO: CHANGE THIS
command = "/usr/local/bin/greetd-session-wrapper Hyprland"

# The default session, also known as the greeter.
[default_session]

command = "tuigreet --time --remember --remember-user-session --asterisks --greeting 'Stop staring and log in already' --theme 'border=magenta;text=cyan;prompt=green;time=red;action=white;button=yellow;container=black;input=gray' --sessions /usr/share/wayland-sessions --xsessions /usr/share/xsessions --session-wrapper /usr/local/bin/greetd-session-wrapper --xsession-wrapper /usr/local/bin/greetd-session-wrapper startx /usr/bin/env"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"
```
