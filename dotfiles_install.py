from lib import Input, Print, Install, Path


def make_backup(backup_floder):
    if Input.yes_no('Do you wish to create a backup of current state of your dotfiles?'):
        Print.action('Creating dotfiles backup')
        Print.err('Backup is not yet implemented')
        # TODO: Create backup
        return True
    else:
        Print.warning('Proceeding without backup')
        return False


def check_installation():
    if Install.check_not_installed('zsh'):
        if not Install.package('zsh', 'default + (This is required shell for dotfiles)'):
            Print.err('Dotfiles installation cancelled - zsh not installed')
            return False

    elif not Path.check_dir_exists('~/.oh-my-zsh ~/oh-my-zsh ~/ohmyzsh ~/.config/oh-my-zsh /usr/shared/oh-my-zsh'):
        # TODO: Option to install
        Print.err('oh-my-zsh is not installed, cannot proceed...')
        return False

    else:
        return True


def personalized_changes(file):
    pass


def init(symlink):
    # Get path to files/ floder (contains all dotfiles)
    files_dir = Path.join_paths(
        Path.get_parent(__file__), 'files')
    # Create optional backup
    make_backup(files_dir)
    # Go through all files
    for file in Path.get_all_files(files_dir):
        # Make personalized changes to files
        personalized_changes(file)
        # Set symlink position ($HOME/filepath)
        position = Path.join_paths(
            Path.get_home(), file.replace(f'{files_dir}/', ''))

        if symlink:
            # Make symlink
            Path.create_symlink(file, position)
        else:
            Path.copy(file, position)


def main():
    Print.action('Installing dotfiles')

    if not check_installation():
        return False

    choice = Input.multiple('Do you wish to create dotfiles', [
                            'symlinks (dotfiles/ dir will be required)', 'files (dotfiles/ dir can be removed afterwards)'])
    # Create symlinks
    if choice == 'symlinks (dotfiles/ dir will be required)':
        init(symlink=True)

        # Final prints
        Print.action('Symlink installation complete')
        Print.warning(
            'Do not delete this floder, all dotfile symlinks are linked to it')
        Print.warning(
            'Deletion would cause errors on all your dotfiles managed by this program')
        Print.comment(
            'If you wish to remove this floder, please select files instead of symlinks for dotfile creation')

    # Create files
    elif choice == 'files (dotfiles/ dir can be removed afterwards)':
        init(symlink=False)

        # Final prints
        Print.action('Dotfiles successfully created')
        Print.comment('This directory can now be removed')

    # Don't create dotfiles
    else:
        Print.cancel('Dotfiles installation cancelled')
        return False


if __name__ == "__main__":
    main()
