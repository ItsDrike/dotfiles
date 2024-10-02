# Battery Optimizations

This guide goes over the various optimizations for laptops that you can
configure to improve your battery life.

> [!IMPORTANT]
> You will need to follow this guide even if you're using my dotfiles, as it
> requires enabling certain services which I don't enable automatically from
> the installation scripts.
>
> This is because not all devices need power management services running
> (desktop devices don't have a battery).

## UPower

UPower is a DBus service that provides power management support to
applications, which can request data about the current power state through this
DBus interface.

Additionally, UPower can perform a certain action when your battery life
reaches a critical point, like entering hibarnation when below 2%.

```bash
pacman -S upower
systemctl start --now upower
```

You can adjust UPower configuration in `/etc/UPower/UPower.conf`, I quite like
the defaults settings here. The relevant settings to look at are:

```conf
PercentageLow=20.0
PercentageCritical=5.0
PercentageAction=2.0
CriticalPowerAction=HybridSleep
```

## Acpid

Acpid is a daemon that can deliver ACPI power management events. When an event
occurs, it executes a program to handle that event. These events are:

- Pressing special keys, including the Power/Sleep/Suspend button, but also
  things like wlan/airplane mode toggle button, volume buttons, brightness, ...
- Closing a notebook lid
- (Un)Plugging an AC power adapter from a notebook
- (Un)Plugging phone jack etc.

By default, these events would otherwise go unhandled, which isn't ideal.

```bash
pacman -S acpid
systemctl enable --now acpid
```

> [!TIP]
> By default `acpid` already has some basic handling of these ACPI events, so
> you shouldn't need to change anything, however, if you would want to run
> something custom on one of these events, you can configure it to do so in
> `/etc/acpi/handler.sh`

## Systemd suspend-then-hibernate

I like to use `systemctl suspend-then-hibernate` command when entering a
suspend state (usually configured from an idle daemon, such as hypridle or
swayidle). This command allows my system to remain suspended for some amount of
time, after which it will enter hibernation. This is really nice, because if I
forget that I had my laptop suspended and leave it like that while unplugged
for a long amount of time, this will prevent the battery from being drained for
no reason.

To configure automatic hibernation with this command, we'll want to modify
`/etc/systemd/sleep.conf`, and add:

```conf
HibernateDelaySec=10800
```

That will configure automatic hibernation after 3 hours of being in a suspend
state.

## Power Profiles Daemon

Many people like using something complex like TLP to manage power, however, in
many cases, you can achieve good results with something much simpler:
`power-profiles-daemon`.

Simply put, `power-profiles-daemon` is a CPU throttle, allowing you to switch
between various "power profiles" (power-saver, balanced, performance). I like
using a custom shell-script that checks the current battery percentage and
status (charging/discharging) and dynamically set the power profile based on
these values.

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> Power Profiles Daemon only performs a subset of what TLP would do. Which of
> these tools you wish to use depends on your workfload and preferences:
>
> - If the laptop frequently runs under medium or high load, such as during
>   video playback or compiling, using `power-saver` profile with
>   `power-profiles-daemon` can provide similar energy savings as TLP.
> - However, TLP offers advantages over `power-profiles-daemon` when the laptop
>   is idle, such as during periods of no user input or low load operations
>   like text editing or browsing.
>
> In my personal opinion, `power-profiles-daemon` is quite sufficient and I
> don't have a great need for TLP. Also TLP is actually quite limiting in it's
> configuration in comparison to being able to use something like a shell script
> and switch profiles depending on both the charging state & the current
> percentage or any other custom rules whereas TLP only exposes some simple
> configuration options, that will enable performance/balanced mode when on AC
> power and power-safe when on battery power, but you can't really mess with
> anything more dynamic.

> [!TIP]
> If you think you'd prefer TLP over `power-profiles-daemon`, feel free to skip
> this section, the section below will cover TLP as an alternative to this.

> [!TIP]
> It may be worth it to look into
> [`system76-power`](https://github.com/pop-os/system76-power) as an
> alternative to `power-profiles-daemon`.

<!-- markdownlint-enable MD028 -->

To set up power-profiles-daemon, we'll first install it and enable it as a
systemd service:

```bash
pacman -S power-profiles-daemon
systemctl enable --now power-profiles-daemon
```

### Setting power profile manually

To try things out, you can set the power profile manually, using
`powerprofilesctl` command:

```bash
powerprofilesctl set power-saver
powerprofilesctl set balanced
powerprofilesctl set performance # won't work on all machines
```

However, having to set your power profile manually each time wouldn't be very
convenient, so I'm only showing this as an example / something you can try out
initially to see what results it can give you.

### Setting power profiles automatically

To make `power-profiles-daemon` actually useful and seamless, I like using a
shell script that monitors the battery state and switches the power mode
depending on certain conditions. I like placing my system-wide scripts into
`/usr/local/bin`, so let's use: `/usr/local/bin/power-profiles-monitor`:

<!-- markdownlint-disable MD013 -->

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "You must run this script as root"
  exit 1
fi

BAT=$(echo /sys/class/power_supply/BAT*) # only supports single-battery systems
BAT_STATUS="$BAT/status"
BAT_CAP="$BAT/capacity"
OVERRIDE_FLAG="/tmp/power-monitor-override"

POWER_SAVE_PERCENT=50 # Enter power-save mode if on bat and below this capacity

HAS_PERFORMANCE="$(powerprofilesctl list | grep "performance" || true)" # the || true ignores grep failing with non-zero code

# monitor loop
prev=0
while true; do
  # check if override is set
  if [ -f "$OVERRIDE_FLAG" ]; then
    echo "Override flag set, waiting for release"
    inotifywait -qq "$OVERRIDE_FLAG"
    continue
  fi

  # read the current state
  status="$(cat "$BAT_STATUS")"
  capacity="$(cat "$BAT_CAP")"

  if [[ $status == "Discharging" ]]; then
    if [[ $capacity -le $POWER_SAVE_PERCENT ]]; then
      profile="power-saver"
    else
      profile="balanced"
    fi
  else
    if [[ -n $HAS_PERFORMANCE ]]; then
      profile="performance"
    else
      profile="balanced"
    fi
  fi

  # Set the new profile
  if [[ "$profile" != "$prev" ]]; then
    echo -en "Setting power profile to ${profile}\n"
    powerprofilesctl set $profile
    prev=$profile
  fi

  # wait for changes in status or capacity files
  # i.e. for the next power change event
  inotifywait -qq "$BAT_STATUS" "$BAT_CAP"
done
```

<!-- markdownlint-enable MD013 -->

> [!NOTE]
> You will need `inotify-tools` package installed for the `inotifywait` command
> to work.

As you can see, it's a pretty simple script, that will run forever, but spend
most time just waiting for the battery status to change, re-running once it
does.

We could now run this script manually, but that's not a great solution,
instead, we can create a custom systemd service which will run it for us
automatically. To do this, we'll create a new file:
`/etc/systemd/system/power-profiles-monitor.service` with the following
content:

```systemd
[Unit]
Description=Monitor the battery status, switching power profiles accordingly
Wants=power-profiles-daemon.service

[Service]
ExecStart=/usr/local/bin/power-profiles-monitor
Restart=on-failure
Type=simple

[Install]
WantedBy=default.target
```

With that, we can now enable our service:

```bash
systemctl daemon-reload # make systemd aware of the new service
systemctl enable --now power-profiles-monitor
```

> [!TIP]
> You may have noticed that the script

## TLP

> [!IMPORTANT]
> TLP is an alternative solution to handle power management, it cannot be used
> in combination with `power-profiles-daemon`.

TODO: This section is work-in-progress, as I'm not using TLP right now.

If you wish to set up TLP, I'd suggest that you check out the official [TLP
documentation](https://linrunner.de/tlp/introduction.html), alongside with a
guide on achieving a similar profile switching behavior as
`power-profiles-daemon` offers with it:
[here](https://linrunner.de/tlp/faq/ppd.html). Additionally, there is an [Arch
Linux Wiki page for TLP](https://wiki.archlinux.org/title/TLP).

## Sources

- <https://wiki.archlinux.org/title/Power_management>
- <https://wiki.archlinux.org/title/Acpid>
- <https://gitlab.freedesktop.org/upower/power-profiles-daemon>
- <https://linrunner.de/tlp/introduction.html>
- <https://linrunner.de/tlp/faq/ppd.html>
- <https://wiki.archlinux.org/title/TLP>
