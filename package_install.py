#!/bin/python3
from util import Print, Install


def main():
    Install.upgrade_pacman()

    Print.action('Package Installation')

    Install.package('networkmanager')
    Install.package(
        'git',
        'default + (Required for some installations, otherwise they\'ll be skipped)'
    )
    Install.package('sudo')

    # Desktop Enviroment
    Install.multiple_packages(
        ['plasma', 'plasma-desktop', 'gnome'],
        'Do you wish to install DE (Desktop Enviroment)?',
        ['Plasma (KDE)', 'Plasma-Desktop (KDE-Minimal dependencies)', 'Gnome'])
    # Display Manager
    Install.multiple_packages(['sddm', 'gdm', 'lightdm'],
                              'Do you wish to install DM (Display Manager)?',
                              ['SDDM (KDE)', 'GDM (Gnome)', 'LightDM'])

    Install.package('base-devel', 'default + (Required for makepkg installs)')
    Install.package('yay', 'default', aur=True)
    Install.package('vim')
    Install.package('exa', 'default + (Better ls tool)')
    Install.package('zsh', 'default + (Shell)')
    Install.package('zsh-syntax-highlighting', 'default')
    Install.package('terminator', 'default + (advanced terminal)')
    Install.package('konsole', 'default + (KDE terminal emulator)')
    Install.package(
        'ark',
        'default + (Managing various archive formats such as tar, gzip, zip, rar, etc.)'
    )
    Install.package('timeshift', 'default + (Backup Tool), aur=True')
    Install.package('cron', 'default + (Task scheduling)')
    Install.package('dolphin', 'default + (File Manager)')
    Install.package('nomacs', 'default + (Photo viewer & editor)')
    Install.package('discord', 'default + (Chat App)')
    Install.package('caprine', 'default + (Unofficial Messenger Chat App)')
    Install.package('spotify', 'default + (Online Music Player)', aur=True)
    Install.package('spectacle', 'default + (Screenshot tool)')
    Install.package('qalculate-gtk-nognome',
                    'Do you wish to install Qalculate! (Complex Calculator)?',
                    aur=True)
    Install.package('gnome-system-monitor',
                    'Do you wish to install gnome system monitor?')
    Install.package(
        'code',
        'Do you wish to install Visual Studio Code (Text/Code Editor)?')
    Install.package('filelight',
                    'default + (Disk usage statistics and graphs)')
    Install.multiple_packages(['firefox', 'chromium'],
                              'Do you wish to install web browser?')

    Print.action('Package Installation Complete')


if __name__ == "__main__":
    main()
