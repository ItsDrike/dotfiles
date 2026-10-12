# Theming

This guide will go over setting up Qt and GTK themes on Arch Linux.

My preferred setup uses:

- [Posy's Cursor Scalable](https://github.com/Morxemplum/posys-cursor-scalable)
  cursor theme, size 24.
- [Papirus-Dark](https://github.com/catppuccin/papirus-folders) icon theme from
  catppuccin papirus folders, specifically the blue accent & mocha flavor
  variant.
- The default font of my choice is [Noto
  Sans](https://fonts.google.com/noto/specimen/Noto+Sans), size 10
- The default monospace font of my choice is [Monaspace
  Krypton](https://monaspace.githubnext.com/), size 10.
- For GTK theme, I'm using
  [Tokyonight-Dark](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme).
- For Qt theme, I'm using
  [Catppuccin-Mocha-Blue](https://github.com/catppuccin/Kvantum) Kvantum theme.

> [!NOTE]
> This repository includes configuration for the choices documented here. The
> guide still describes the manual setup, so it remains useful independently of
> the repository and makes the configuration easier to understand.
>
> The Chezmoi configuration deploys the user configuration files and imports the
> documented desktop-interface GSettings values whenever `chezmoi apply` runs.
> Package installation remains separate from that user configuration.

## Packages

First, we'll install all the required packages:

```bash
paru -S --needed \
  dconf gsettings-desktop-schemas \
  gtk3 gtk4 \
  qt5-wayland qt6-wayland qt5ct qt6ct \
  kvantum kvantum-qt5 kvantum-theme-catppuccin-git \
  tokyonight-gtk-theme-git \
  papirus-icon-theme papirus-folders-catppuccin-git \
  posys-cursor-scalable \
  fontconfig noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-dejavu ttf-liberation otf-monaspace ttf-nerd-fonts-symbols-mono
```

## Dconf / Gsettings

Dconf is a low-level configuration system that works through D-Bus, serving as
the backend to GSettings. It is a simple key-based configuration system whose
keys are stored in a database.

You can use the `dconf` command manually to load or set specific keys, but it is
often better to use `gsettings`. It provides schema-aware access and consistency
checking, while ultimately storing the configured values in the `dconf` database.

Dconf is used by a lot of applications for various things, but a lot of the
dconf settings are related to theming and it's crucial that we set them, as some
applications will follow these instead of the configuration files.

> [!NOTE]
> This repository imports these values from a declarative dconf keyfile whenever
> `chezmoi apply` runs. If you are following this guide manually, run the
> commands below yourself.

```bash
# Global configuration that tells applications to prefer dark mode
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Font settings
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monaspace Krypton 10'

# Cursor settings
gsettings set org.gnome.desktop.interface cursor-theme 'Posys_Cursor'
gsettings set org.gnome.desktop.interface cursor-size 24
```

> [!TIP]
> You can find all registered dconf schemas with `gsettings list-schemas`. To
> list their keys, use `gsettings list-recursively`.
>
> You might want to set some of these according to your preferences.

## XSettings

Alongside the Dconf/GSettings system, there is also an XSETTINGS specification
that is used by some Xorg applications (most notably GTK, Java,
and Wine based apps). It is less useful on Wayland, but since a lot of
applications still don't have native wayland support, it may be worth setting
up anyways. XWayland applications may still depend on this.

Applications that rely on this specification will ask for the settings from the
Xorg server, which itself gets them from a daemon service. On GNOME desktop,
this would be `gnome-settings-daemon`, but anywhere else, you'll want to use
[`xsettingsd`](https://codeberg.org/derat/xsettingsd), which is a lightweight
alternative.

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> This part of the guide is optional, you don't have to set up xsettings, most
> applications will work just fine without it.

> [!IMPORTANT]
> If you do wish to set up XSettings, you will need to install the package,
> configure it, and activate its user service. This repository does not
> currently manage that optional setup.

<!-- markdownlint-enable MD028 -->

First, you will want to install the `xsettingsd` package and activate its
systemd service, so that applications can ask this daemon for a specific setting:

```bash
pacman -S xsettingsd
systemctl --user enable --now xsettingsd
```

These settings can control various things, but for us, we'll focus on the
theming. XSettings are configured simply through a config file in:
`~/.config/xsettingsd/xsettingsd.conf`.

To configure theming in xsettings, you can put the following settings into your
`xsettingsd.conf` file:

```conf
Net/ThemeName "Tokyonight-Dark"
Net/IconThemeName "Papirus-Dark"
Gtk/CursorThemeName "Posys_Cursor"
Net/EnableEventSounds 0
EnableInputFeedbackSounds 0
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintslight"
Xft/RGBA "rgb"
```

## GTK

> [!TIP]
> We'll be setting things up manually, however, if you wish, you can also use
> [`nwg-look`](https://github.com/nwg-piotr/nwg-look) to configure GTK from a
> graphical settings application. Do note though that by default, it doesn't
> support GTK 4 theming (see: [this github
> issue](https://github.com/nwg-piotr/nwg-look/issues/22)).
>
> `nwg-look` is inspired by the more popular `lxappearance`, however, it is
> made for native wayland. That said, either will work, so you can also try
> `lxappearance` if you wish, even on wayland.

### GTK 2

For GTK 2, we'll first want to change the location of the `gtkrc` configuration
file, to follow proper XDG base directory specification and avoid it cluttering
`$HOME`. To do this, we'll need to set the following environment variable in the
graphical session, for example by exporting it from your shell:

```bash
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
```

We'll now create `~/.config/gtk-2.0` directory, and a `gtkrc` file inside of it,
with the following content:

```text
gtk-theme-name = "Tokyonight-Dark"
gtk-icon-theme-name = "Papirus-Dark"
gtk-cursor-theme-name = "Posys_Cursor"
gtk-cursor-theme-size = 24
gtk-font-name = "Noto Sans 10"
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
```

### GTK 3

For GTK 3, we'll put the following into `~/.config/gtk-3.0/settings.ini`:

```conf
[Settings]
gtk-application-prefer-dark-theme=true
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Posys_Cursor
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 10
gtk-enable-animations=true
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-error-bell=0
gtk-decoration-layout=appmenu:none
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
```

### GTK 4

For GTK 4, we'll put the following into `~/.config/gtk-4.0/settings.ini`:

```conf
[Settings]
gtk-application-prefer-dark-theme=true
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Posys_Cursor
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 10
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-error-bell=0
gtk-decoration-layout=appmenu:none
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
```

GTK 4 applications built on libadwaita intentionally follow the desktop
light/dark preference rather than a third-party GTK theme name. They should use
the dark preference configured through GSettings above, but they do not support
arbitrary custom theming as a stable interface.

It is possible to force a theme with `GTK_THEME`, or to import a theme stylesheet
from `~/.config/gtk-4.0/gtk.css`. Both approaches can affect some libadwaita
applications when the selected theme includes GTK 4 assets, but they override
upstream styling assumptions and can break after GTK, libadwaita, or theme
updates. For that reason, this setup does not use either approach:

```bash
# Experimental, process-wide override; not part of the recommended setup.
export GTK_THEME="Tokyonight-Dark"
```

```css
/* Experimental user CSS override; not part of the recommended setup. */
@import url("file:///usr/share/themes/Tokyonight-Dark/gtk-4.0/gtk.css");
```

### Make GTK follow XDG portal settings

XDG desktop portals can provide standard dialogs and file pickers. To ask GTK
applications to use the portal implementation, export the following environment
variable:

```bash
export GTK_USE_PORTAL=1
```

## Qt

This section goes over configuring Qt styles for Qt 5 and Qt 6.

### Kvantum

I like using `kvantum` to configure Qt themes. Kvantum is an SVG-based Qt
Widgets style engine that renders installed Kvantum themes. For theme creators,
it simplifies making a complete Qt Widgets style.

> [!NOTE]
> Kvantum will only be useful for you if you actually want to use a Kvantum
> theme. If you wish to use a full Qt theme that doesn't need Kvantum, you can
> skip this and instead achieve the same with qtct. (I'll say a bit more about
> qtct in icon theme section.)

Kvantum works as a Qt Widgets style instead of a Qt platform theme. To select
Kvantum for Qt Widgets applications, export the following environment variable:

```bash
export QT_STYLE_OVERRIDE=kvantum
```

> [!NOTE]
> For Qt 5 support, install `kvantum-qt5` in addition to `kvantum`, which
> provides Qt 6 support.

### Theme

We will now want to tell Kvantum which theme to use. To do this, we will need to
create a settings file for Kvantum in `~/.config/Kvantum/kvantum.kvconfig`, with
the following content:

```conf
[General]
theme=catppuccin-mocha-blue
```

> [!TIP]
> The system-wide Kvantum themes are located in `/usr/share/Kvantum`. The theme
> variable has to match the directory name of one of these themes.
>
> If you wish to use a custom theme that isn't available as a package, you can
> also add it as a user theme directly into `~/.config/Kvantum/`.

### Icon theme & qtct

As a Qt Widgets style engine, Kvantum does not choose an icon theme. For that,
we will use the qtct platform theme.

> [!NOTE]
> You will need to install `qt5ct` & `qt6ct` packages. These will also be
> installed already if you followed the initial install command though.

Now we'll set the Qt platform theme through an environment variable:

```bash
export QT_QPA_PLATFORMTHEME="qt5ct"  # Qt 6 recognizes this as the qt6ct alias
```

Finally, we can add a qtct configuration to use our preferred icon theme:

`~/.config/qt5ct/qt5ct.conf`:

```conf
[Appearance]
icon_theme=Papirus-Dark
```

Use the same configuration for `~/.config/qt6ct/qt6ct.conf`. Qt 5 loads the
qt5ct plugin and configuration, while Qt 6 recognizes the `qt5ct` selector as a
compatibility alias and loads qt6ct with its own configuration.

> [!NOTE]
> qtct is a platform theme and it can do a lot more than just set the icon
> theme, however, we chose kvantum to serve as our style, so we don't need
> anything else from qtct.
>
> If you wish to instead use qtct for picking the qt style, unset the
> `QT_STYLE_OVERRIDE` variable and pick your theme in both `qt5ct` & `qt6ct`
> applications. This will modify the `qt5ct.conf` and the qt 6 variant.

### Additional things

To prefer native Wayland while retaining an X11 fallback for applications that
need it, export the following environment variable:

```bash
export QT_QPA_PLATFORM="wayland;xcb"
```

Modern Qt handles high-DPI scaling automatically, so this setup does not set
`QT_AUTO_SCREEN_SCALE_FACTOR`; it is a legacy override and can conflict with a
compositor's scale configuration. `QT_SCALE_FACTOR` remains available if you
intentionally need one global Qt scale override.

`QT_WAYLAND_DISABLE_WINDOWDECORATION=1` is another optional override. It asks Qt
Wayland applications not to use their client-side window decorations. Decoration
negotiation and support vary by compositor and application, so it is not part of
the general setup.

## Cursor

### XCursor

XCursor is the default cursor format for cursor themes. Even though the name
might imply that it's connected to X11, it will work just fine on wayland too.

To select a cursor theme to be used, you'll want to export the following
environment variables:

```bash
export XCURSOR_THEME="Posys_Cursor"
export XCURSOR_SIZE="24"
```

Additionally, you might want to also modify/set `XCURSOR_PATH`, to make sure
that it includes `~/.local/share/icons`, as otherwise, xcursor will not look
here for cursor themes by default on some DEs/WMs.

```bash
export XCURSOR_PATH=$XCURSOR_PATH${XCURSOR_PATH:+:}$HOME/.local/share/icons
```

### Default cursor config

The cursor theme name "default" is used by an application if it cannot pick up
on a configuration. The default cursor theme can live in:
`~/.local/share/icons/default` or `/usr/share/icons/default`.

To set the default cursor for your user, create a
`~/.local/share/icons/default/index.theme` file with the following:

```conf
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Posys_Cursor
```

> [!TIP]
> Alternatively, we could also symlink the cursor theme into the `default`
> directory, like so:
>
> ```bash
> ln -s /usr/share/icons/Posys_Cursor/ ~/.local/share/icons/default
> ```
>
> That said, I prefer using `Inherits` here, as it allows me to easily store the
> default cursor config in my dotfiles.

### Cursor config for GTK

You may have noticed earlier that we've already touched on specifying the cursor
configuration for GTK in the gtkrc/gtk settings, this is done via the
`gtk-cursor-theme-name` and `gtk-cursor-theme-size` setting options. Because of
that, there's no need to do anything extra to get GTK apps to use the correct
cursor theme.

### Cursor config for Qt

There is no Qt configuration for cursors. Qt programs may pick up a cursor theme
from the desktop environment (server-side cursors), X resources, or lastly the
"default" cursor theme.

### Hyprcursor

[hyprcursor](https://github.com/hyprwm/hyprcursor) is a new and efficient
cursor format that allows SVG-based cursors, resulting in a much better
scaling experience and more space-efficient themes.

Hyprcursor is supported out of the box by Hyprland, so if you're using Hyprland,
you can benefit from it. That said, this part is entirely optional and you can
just stick with xcursor if you wish.

The `posys-cursor-scalable` package provides both XCursor and Hyprcursor
themes, so you can simply configure hyprcursor to use it:

```bash
export HYPRCURSOR_THEME="Posys-Cursor-Scalable"
export HYPRCURSOR_SIZE="24"
```

Alternatively, you can also set these variables right from your hyprland config:

```hyprlang
env = HYPRCURSOR_THEME,Posys-Cursor-Scalable
env = HYPRCURSOR_SIZE,24
```

To apply the hyprcursor config immediately, from a running Hyprland instance,
without having to re-login, you can run:

```bash
hyprctl setcursor Posys-Cursor-Scalable 24
```

This is also a nice way to quickly test out other cursor themes.

> [!TIP]
> Alternatives:
> - [Nordzy White](https://gitlab.com/gboehm/Nordzy-cursors) provides matching
>   XCursor and Hyprcursor themes through `nordzy-cursors` and
>   `nordzy-hyprcursors` packages
> - [Rose Pine
>   Hyprcursor](https://github.com/ndom91/rose-pine-cursor-hyprcursor) provides
>   a dark Hyprcursor alternative, through `rose-pine-hyprcursor` package.

> [!WARNING]
> Make sure to keep the existing xcursor environment variables and themes, as
> although many apps do support server-side cursors (e.g. Qt, Chromium,
> Electron, ...), some still don't (looking at you GTK, but also some other,
> less common things). These applications will then fall back to XCursor (unless
> they have built-in hyprcursor support, which is rare).
>
> I would therefore also recommend leaving the default theme point to the
> XCursor theme, not to a hyprcursor theme.

## Fonts

Some applications use `gsettings`/`dconf` to figure out what font to use. We've
already configured these settings, so those applications should pick up which
font to use correctly.

Other applications will use GTK config to figure out the default fonts. We've
configured this earlier too. (Note that GTK config doesn't support specifying a
monospace font).

The rest of the applications will use generic font family names ("standard"
fonts), as defined through `fontconfig`.

Applications also often provide configuration files where you can define which
font you wish to be using, so sometimes, you will need to set the font on a
per-application basis. We will not cover this, as each application is different.

### Installing fonts

The selected fonts and fallback coverage can be installed with:

```bash
paru -S --needed \
  fontconfig noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-dejavu ttf-liberation otf-monaspace ttf-nerd-fonts-symbols-mono
```

`ttf-nerd-fonts-symbols-mono` provides common terminal and prompt glyphs without
installing the full collection of patched Nerd Font families.

### Setting standard fonts

These standard fonts are:

- `sans-serif`: Standard font for regular text (articles, menus, ...)
- `serif`: Like sans-serif, but pure sans fonts shouldn't have the decorative
  lines or tapers (also known as "tails" or "feet"). Note that these should fall
  back to `sans-serif` if unset.
- `monospace`: Standard font for fixed-width fonts (text editors, calculators,
  ...)
- `emoji`: Standard font for emoji glyphs

It is possible to register multiple fonts for the standard font, ordered by
priorities. That way, if the first font isn't found, or it doesn't contain the
given glyph, the search will fall back to the next font in line.

To set a standard font, you will need to create a fontconfig configuration file.
You can do this on a per-user basis, in `~/.config/fontconfig/fonts.conf` (or
`~/.config/fontconfig/conf.d/`) or system-wide in `/etc/fonts/local.conf` (don't
modify `/etc/fonts/fonts.conf` nor the files in `/etc/fonts/conf.d`, these are
managed by the package manager and could get overwritten). Note that the user
font settings will take priority if there are overlapping settings.

I prefer using the system-wide settings (`/etc/fonts/local.conf`):

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
    </prefer>
  </alias>

  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>Monaspace Krypton</family>
      <family>Symbols Nerd Font Mono</family>
    </prefer>
  </alias>

  <alias>
    <family>emoji</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
```

You will now need to rebuild the font cache with:

```bash
fc-cache -vf
```

### Font Manager

To preview the installed fonts, I like using `font-manager`:

```bash
paru -S --needed font-manager
```

## Sources

- <https://askubuntu.com/questions/22313/what-is-dconf-what-is-its-function-and-how-do-i-use-it>
- <https://man.archlinux.org/man/dconf.1.en>
- <https://wiki.archlinux.org/title/Xsettingsd>
- <https://www.reddit.com/r/gnome/comments/wt8oml/is_gnomesettingsdaemon_no_longer_a_program_i_can/>
- <https://wiki.archlinux.org/title/GTK>
- <https://wiki.archlinux.org/title/XDG_Base_Directory>
- <https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications>
- <https://wiki.archlinux.org/title/Qt>
- <https://wiki.archlinux.org/title/Cursor_themes>
- <https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/>
- <https://wiki.archlinux.org/title/Font_configuration>
- <https://bbs.archlinux.org/viewtopic.php?id=275434>
