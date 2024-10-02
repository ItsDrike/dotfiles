# Theming

This guide will go over setting up Qt and GTK themes on Arch Linux.

My preferred setup uses:

- [BreezeX-RosePine-Linux](https://github.com/rose-pine/cursor) cursor theme,
  size 24.
- [Papirus-Dark](https://github.com/catppuccin/papirus-folders) icon theme from
  catppuccin papirus folders, specifically the blue accent & mocha flavor
  variant.
- The default font of my choice is [Noto
  Sans](https://fonts.google.com/noto/specimen/Noto+Sans), size 10
- The default monospace font of my choice is [Monaspace
  Krypton](https://monaspace.githubnext.com/)
- For GTK theme, I'm using
  [Tokyonight-Dark](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme).
- For QT theme, I'm using
  [Catppuccin-Mocha-Blue](https://github.com/catppuccin/Kvantum) kvantum theme.

> [!NOTE]
> My dotfiles already include most of the necessary theme configuration files,
> so if you're using them, you can skip a lot of the steps I mention here. This
> guide assumes a completely un-themed system, to make it easy for anyone to
> follow.
>
> If there is something that you're expected to do even if you've copied over
> all of the configuration files from my dotfiles repo, it will be explicitly
> mentioned in an _important_ markdown block.

## Packages

First, we'll install all the required packages:

```bash
paru -S --needed \
rose-pine-cursor \
papirus-folders-catppuccin-git \
noto-fonts otf-monaspace \
tokyonight-gtk-theme-git \
kvantum kvantum-qt5 qt5ct qt6ct kvantum-theme-catppuccin-git
```

## Dconf / Gsettings

Dconf is a low-level configuration system that works through D-Bus, serving as
backend to GSettings. It's a simple key-based config systems, with the keys
existing in an unstructured database.

You can use the `dconf` command manually to set specific keys to given values,
but it's often more a better idea to use `gsettings`, which provide some
abstractions and does consistency checking, but ultimately it will just store
the configured values into the `dconf` database.

Dconf is used by a lot of applications for various things, but a lot of the
dconf settings are related to theming and it's crucial that we set them, as some
applications will follow these instead of the configuration files.

> [!IMPORTANT]
> You will need to perform this step even if you're using my dotfiles. The
> dconf database is not a part of my dotfiles, so these values won't be set.

```bash
# Global configuration that tells applications to prefer dark mode
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme Tokyonight-Dark

# Font settings
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'

# Cursor settings
gsettings set org.gnome.desktop.interface cursor-theme 'BreezeX-RosePine-Linux'
gsettings set org.gnome.desktop.interface cursor-size 24
```

> [!TIP]
> You can find all registered dconf schemas with `gsettings list-schemas`. To
> include the keys, you can `gsettings list-recursively`.
>
> You might want to set some of these according to your preferences.

## XSettings

Similarly to dconf/gsettings specification, there's also an XSETTINGS
specification, that is used by some Xorg applications (most notably GTK, Java
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
> If you do wish to set up xsettings, you will need to follow these
> instructions, even if you've populated your system with the configuration
> files from my dotifiles, as it requires installing a package and activating a
> systemd service.

<!-- markdownlint-enable MD028 -->

First, you will want to install `xsettingd` package and activate the systemd
service, so that applications can ask for this daemon a specific setting:

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
Gtk/CursorThemeName "BreezeX-RosePine-Linux"
Net/EnableEventSounds 1
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
`$HOME`. To do this, we'll need to set the following environment variable to be
exported by your shell:

```bash
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
```

We'll now create `~/.config/gtk-2.0` directory, and a `gtkrc` file inside of it,
with the following content:

```text
gtk-theme-name = "Tokyonight-Dark"
gtk-icon-theme-name = "Papirus-Dark"
gtk-cursor-theme-name = "BreezeX-RosePine-Linux"
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
gtk-cursor-theme-name=BreezeX-RosePine-Linux
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
gtk-cursor-theme-name=BreezeX-RosePine-Linux
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

For `libadwaita` based GTK 4 applications, you will need to force a GTK theme
with an environment variable, so you will also want to export the following:

```bash
export GTK_THEME="Tokyonight-Dark"
```

<!-- markdownlint-disable MD028 -->

> [!WARNING]
> This will only work if your theme has GTK 4 support.

> [!TIP]
> As an alternative to exporting the `GTK_THEME` env var like this, you can
> also install `libadwaita-without-adwaita-git` AUR package, which contains a
> patch to prevent GTK from overriding the system theme.
>
> Another option would be to import the theme in `gtk.css`: `~/.config/gtk-4.0/gtk.css`:
>
> ```css
> /**
> * GTK 4 reads the theme configured by gtk-theme-name, but ignores it.
> * It does however respect user CSS, so import the theme from here.
> **/
> @import url("file:///usr/share/themes/Tokyonight-Dark/gtk-4.0/gtk.css");
> ```

<!-- markdownlint-enable MD028 -->

### Make GTK follow XDG portal settings

Certain things, such as dialogs or file-pickers can be controlled via XDG
desktop portals, however, by default, GTK apps will not follow these settings.
To force them into doing so, you can export an environment variable:

```bash
export GTK_USE_PORTAL=1
```

## Qt

This section goes over configuring QT styles for qt 5 and qt 6.

### Kvantum

I like using `kvantum` to configure QT themes. Kvantum is an SVG style
customizer/engine, for which there's a bunch of plugins. It then turns these
plugins / kvantum themes into full QT themes. For theme creators, it simplifies
making a full QT theme.

> [!NOTE]
> Kvantum will only be useful for you if you actually want to use a kvantum
> theme. If you wish to use a full QT theme that doesn't need kvantum, you can
> skip this and instead achieve the same with qtct. (I'll say a bit more about
> qtct in icon theme section.)

Kvantum works as a Qt style instead of a Qt platform theme. To set kvantum for
all Qt applications, you can export the following env variable:

```bash
export QT_STYLE_OVERRIDE=kvantum
```

> [!NOTE]
> For backwards compatibility, in addition to the `kvantum` package, you will
> also need `kvantum-qt5` (`kvantum` works with qt6). If you followed the
> initial install instructions, you will have both installed already.

### Theme

We will now want to tell kvantum which theme to use. To do this, we will need to
create a settings file for Kvantum in `~/.config/Kvantum/kvantum.kvconfig`, with
the following content:

```conf
[General]
theme=catppuccin-mocha-blue
```

> [!TIP]
> The system-wide kvantum themes are located in `/usr/share/Kvantum`. The theme
> variable has to match the directory name of one of these themes.
>
> If you wish to use a custom theme that isn't available as a package, you can
> also add it as a user theme directly into `~/.config/Kvantum/`.

### Icon theme & qtct

As a theme qt engine, kvantum can't handle icons. For those, we will use qtct
platform theme.

> [!NOTE]
> You will need to install `qt5ct` & `qt6ct` packages. These will also be
> installed already if you followed the initial install command though.

Now we'll set the QT platform theme through an environment variable:

```bash
export QT_QPA_PLATFORMTHEME="qt5ct"  # keep this value even for qt6ct
```

Finally, we can add a qtct configuration to use our preferred icon theme:

`~/.config/qt5ct/qt5ct.conf`:

```conf
[Appearance]
icon_theme=Papirus-Dark
```

Same thing for `~/.config/qt6ct/qt6ct.conf`.

> [!NOTE]
> qtct is a platform theme and it can do a lot more than just set the icon
> theme, however, we chose kvantum to serve as our style, so we don't need
> anything else from qtct.
>
> If you wish to instead use qtct for picking the qt style, unset the
> `QT_STYLE_OVERRIDE` variable and pick your theme in both `qt5ct` & `qt6ct`
> applications. This will modify the `qt5ct.conf` and the qt 6 variant.

### Additional things

There are some extra things that you'll probably want to set. To do so, we will
yet again use more environment variables. Specifically:

```bash
# Enables automatic scaling, based on the monitor's pixel density.
export QT_AUTO_SCREEN_SCALE_FACTOR="1"
# Run QT applications using the wayland plugin, falling back to xcb (X11) plugin
export QT_QPA_PLATFORM="wayland;xcb"
# Disable client side decorations
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
```

## Cursor

### XCursor

XCursor is the default cursor format for cursor themes. Even though the name
might imply that it's connected to X11, it will work just fine on wayland too.

To select a cursor theme to be used, you'll want to export the following
environment variables:

```bash
export XCURSOR_THEME="BreezeX-RosePine-Linux"
export XCURSOR_SIZE="24"
```

Additionally, you might want to also modify/set `XCURSOR_PATH`, to make sure
that it includes `~/.local/share/icons`, as otherwise, xcursor will not look
here for cursor themes by default on some DEs/WMs.

```bash
export XCURSOR_PATH=$XCURSOR_PATH${XCURSOR_PATH:+:}~/.local/share/icons
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
Inherits=BreezeX-RosePine-Linux
```

> [!TIP]
> Alternatively, we could also symlink the cursor theme into the `default`
> directory, like so:
>
> ```bash
> ln -s /usr/share/icons/BreezeX-RosePine-Linux/ ~/.local/share/icons/default
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

[hyprcursor](https://github.com/hyprwm/hyprcursor) is a new and efficient a
cursor format, that allow for SVG based cursors, resulting in a much better
scaling experience and more space-efficient themes.

Hyprcursor is supported out of the box by Hyprland, so if you're using Hyprland,
you can benefit from it. That said, this part is entirely optional and you can
just stick with xcursor if you wish.

If you do want to use hyprcursor, you will want to install [hyprcursor version
of the rose-pine-cursor
theme](https://github.com/ndom91/rose-pine-cursor-hyprcursor). You can simply
git clone this repository right into `~/.local/share/icons` (sadly, there isn't
an AUR package available at this time):

```bash
cd ~/.local/share/icons
git clone https://github.com/ndom91/rose-pine-cursor-hyprcursor
```

Finally, you will want to set the following environment variables:

```bash
export HYPRCURSOR_THEME="rose-pine-hyprcursor"
export HYPRCURSOR_SIZE="24"
```

Alternatively, you can also set these variables right from your hyprland config:

```hyprlang
env = HYPRCURSOR_THEME,rose-pine-hyprcursor
env = HYPRCURSOR_SIZE,24
```

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

In the installation instructions above, I did specify the 2 default font
packages that I wanted to use for my system. That said, I did not specify an
emoji font there and there are many fonts that are just useful to have on the
system, for things like text editing. The command below will install most of the
fonts that you might need:

```bash
paru -S --needed \
  libxft xorg-font-util \
  ttf-joypixels otf-jost lexend-fonts-git ttf-sarasa-gothic \
  ttf-roboto ttf-work-sans ttf-comic-neue \
  gnu-free-fonts tex-gyre-fonts ttf-liberation otf-unifont \
  inter-font ttf-lato ttf-dejavu noto-fonts noto-fonts-cjk \
  noto-fonts-emoji ttf-material-design-icons-git \
  ttf-font-awesome ttf-twemoji otf-openmoji \
  adobe-source-code-pro-fonts adobe-source-han-mono-otc-fonts \
  adobe-source-sans-fonts ttf-jetbrains-mono otf-monaspace \
  ttf-ms-fonts
```

#### Nerd fonts

I have intentionally left out the `nerd-fonts` package from the above command,
as it is fairly large (about 8 gigabytes). If you wish, you can install it, as
it does contain some pretty useful fonts, however, if this package is too big
for you, you can instead install the fonts individually, as arch does ship all
nerd fonts in the package manager individually.

To install all nerd fonts, you can simply:

```bash
paru -S --needed nerd-fonts
```

If you instead wish to only install specific nerd fonts, you can use the
following command. Note that you may want to add more fonts from nerd-fonts.

```bash
paru -S --needed \
  ttf-firacode-nerd otf-firamono-nerd ttf-iosevka-nerd ttf-nerd-fonts-symbols \
  ttf-hack-nerd ttf-heavydata-nerd ttf-gohu-nerd
```

> [!IMPORTANT]
> If you wish to use all of nerd-fonts, you will need to run the above command
> even after going through the install scripts from my dotfiles, as they only
> install specific nerd fonts (the above).

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
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias binding="same">
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Jost</family>
      <family>Lexend</family>
      <family>Iosevka Nerd Font</family>
      <family>Symbols Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <alias binding="same">
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>Iosevka Nerd Font</family>
      <family>Symbols Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <alias binding="same">
    <family>monospace</family>
    <prefer>
      <family>Monaspace Krypton</family>
      <family>Source Code Pro Medium</family>
      <family>Source Han Mono</family>
      <family>Iosevka Nerd Font</family>
      <family>Symbols Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <alias binding="same">
    <family>emoji</family>
    <prefer>
      <family>Noto Color Emoji</family>
      <family>Iosevka Nerd Font</family>
      <family>Symbols Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
```

You will now need to rebuild the font cache with:

```bash
fc-cache -vf
```

### Disable Caskaydia Cove Nerd Font

For some reason, having the Caskaydia font installed was causing some issues
with other fonts for me. Caskaydia comes from `nerd-fonts`, so if you installed
them, you might want to follow along with this too, if you're also facing
issues. I'm honestly not sue why that is, however, all that's needed to solve it
is disabling this font entirely. To do so, add the following to your
`fontconfig` config:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">

<fontconfig>
  <selectfont>
    <rejectfont>
      <glob>/usr/share/fonts/nerd-fonts-git/TTF/Caskaydia*</glob>
    </rejectfont>
  </selectfont>
</fontconfig>
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
