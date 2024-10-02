# Printing

This guide explains how to set up printing and scanning on Arch Linux.

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> This guide is still WIP and isn't very informative, I wrote it just as a quick
> reference for myself.

> [!NOTE]
> This guide focuses on HP brand printers. If you have a printer from another
> brand, you will not be able to fully follow it.

<!-- markdownlint-enable MD028 -->

## Installing

First, we'll need to install and enable `cups`, which is the printing daemon for
Linux.

```bash
sudo pacman -S --needed cups
systemctl enable --now cups
```

### HP printers

You'll want to use `hplip` if you're using an HP brand printer.

```bash
sudo pacman -S --needed hplip
```

> [!NOTE]
> You will only want to use the hplip package for terminal based interactions.
>
> Hplip should support UI too, however, it uses Qt 4, for which the necessary
> libraries are no longer shipped by pacman, as it's incredibly outdated. It is
> technically possible to install these through the AUR, but due to the nature
> of some of the dependencies for these outdated libraries, it would mean having
> to install python2 and a bunch of related packages.
>
> Additionally, because hplip was written for very early python 3, you are
> likely to see a lot of warnings when you run most commands. That said, the
> commands should work, as these are just warnings.
>
> Aren't drivers written by big companies that have no clue about Linux just the
> best?

To set up your printer, run:

```bash
sudo hp-setup -i
```

This will register the printer with CUPS and you should now be able to pick it
in the printing dialog.

## Scanning

To get scanning support, you will need to have `sane`:

```bash
sudo pacman -S sane
```

If you're using `hplip`, you can now trigger a scan with the following command:

```bash
hp-scan -o scan.png
```

> [!TIP]
> If the specified filename ends with `.pdf`, hplip will store a PDF document
> instead of a PNG image.
