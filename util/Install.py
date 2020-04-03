#!/bin/python3
import os
import shutil

from util import Command, Input, Print, Path


def _generate_install_text(install_text, package_name, yay=False, git=False):
    if install_text == 'default':
        install_text = f'Do you wish to install {package_name}?'
    if install_text[:10] == 'default + ':
        install_text = f'Do you wish to install {package_name}? {install_text[10:]}'
    if yay:
        install_text += '[AUR (YAY) Package]'
    if git:
        install_text += '[AUR (GIT+MAKEPKG) Package]'
    return install_text


def check_installed(package_name):
    '''Check if specified package is currently installed

    Arguments:
        package_name {str} -- name of package/es to check

    Returns:
        bool -- is/are package/ss not installed?
    '''
    if type(package_name) == list:
        package_name = ' '.join(package_name)
    if type(package_name) == str:
        out = Command.get_return_code(f'pacman -Qi {package_name}')
        if out != 1:
            # INSTALLED
            return True
        else:
            # NOT INSTALLED
            return False
    else:
        raise TypeError(
            'check_installed() only takes string or list parameters')


def check_not_installed(package_name):
    if type(package_name) == str:
        package_name = package_name.split(' ')
    elif type(package_name) != list:
        Print.err(
            'Function Install.check_not_installed() only accepts string or list parameters'
        )
        raise TypeError(
            'check_not_installed() only takes string or list parameters')
    if package_name == ['base-devel']:
        # Check dependencies for base-devel (group packages are not detected directly)
        return check_not_installed(
            'guile libmpc autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed sudo texinfo which'
        )
    for package in package_name:
        if check_installed(package):
            return False
            break
    else:
        return True


def git_aur(repository, install_text='default', force=False):
    '''Install package directly from AUR using only git and makepkg

    Arguments:
        repository {string} -- repository name

    Keyword Arguments:
        install_text {str} -- text presented to the user before installing (default: {'default' -> 'Do you wish to install [repository]'})
        force {bool} -- should the repository be installed even if detected as installed (default: {False})

    Returns:
        bool -- installed
    '''

    if check_not_installed('git'):
        Print.warning(
            f'Unable to install AUR repository: {repository}, git is not installed'
        )
        return False

    # Base-devel group includes (required for makepkg)
    if check_not_installed('base-devel'):
        Print.warning(
            f'Unable to install AUR repository: {repository}, base-devel is not installed'
        )
        return False

    if check_not_installed(repository) or force:
        install_text = _generate_install_text(install_text,
                                              repository,
                                              git=True)
        if Input.yes_no(install_text):
            url = f'https://aur.archlinux.org/{repository}.git'
            Command.execute(f'git clone {url}')
            os.chdir(repository)
            Command.execute('makepkg -si')
            os.chdir(Path.get_parent(__file__))
            shutil.rmtree(repository)
            return True
        else:
            Print.cancel('Skipping...')
            return False
    else:
        Print.cancel(
            f'assuming {repository} already installed ({repository} is installed)'
        )
        return True


def package(package_name, install_text='default', aur=False, reinstall=False):
    '''Installation of package

    Arguments:
        package_name {str} -- name of package to be installed

    Keyword Arguments:
        install_text {str} -- text presented to user before installing (default: {'default' -> 'Do you wish to install [package_name]'})
        use_yay {bool} -- use yay for package installation (default: {False})
        reinstall {bool} -- should the package be reinstalled (default {False})

    Returns:
        bool -- installed
    '''
    if aur:
        if check_not_installed('yay'):
            Print.cancel(
                f'Unable to install with yay (not installed), installing AUR package: {package_name} with git instead'
            )
            git_aur(package_name, install_text)
    if check_not_installed(package_name) or reinstall:
        install_text = _generate_install_text(install_text,
                                              package_name,
                                              yay=aur)
        if Input.yes_no(install_text):
            if aur:
                Command.execute(f'yay -S {package_name}')
            else:
                Command.execute(f'sudo pacman -S {package_name}')
            return True
        else:
            Print.cancel('Skipping...')
            return False
    else:
        Print.cancel(f'{package_name} already installed')
        return True


def multiple_packages(packages, install_text, options=False, reinstall=False):
    '''Installation of multiple packages

    Arguments:
        packages {list} -- list of packages to choose from
        install_text {str} -- text presented to user when picking which package to install
        options {list} -- list of options to choose from (must be in same order as packages)

    Returns:
        bool/str -- False if none / chosen package name
    '''
    if check_not_installed(packages) or reinstall:
        if not options:
            options = packages
        choice = Input.multiple(f'{install_text}', options)
        if choice:
            for index, option in enumerate(options):
                if choice == option:
                    Command.execute(f'sudo pacman -S {packages[index]}')
                    return packages[index]
        else:
            Print.cancel('Skipping...')
            return False
    else:
        for package in packages:
            if not check_not_installed(package):
                Print.cancel(f'{package} already installed')
        return False


def upgrade_pacman():
    if Input.yes_no(
            'Do you wish to Sync(S), refresh(y) and upgrade(u) pacman - Recommended?'
    ):
        Command.execute('sudo pacman -Syu')
    else:
        Print.warning('Pacman upgrade cancelled.')
