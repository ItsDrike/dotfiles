from lib import Input, Print, Install, Path
import os


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

    global oh_my_zsh_path
    oh_my_zsh_path = None
    if Path.check_dir_exists('~/.oh-my-zsh'):
        oh_my_zsh_path = '$HOME/.oh-my-zsh'
    elif Path.check_dir_exists('~/oh-my-zsh'):
        oh_my_zsh_path = '$HOME/oh-my-zsh'
    elif Path.check_dir_exists('~/ohmyzsh'):
        oh_my_zsh_path = '$HOME/ohmyzsh'
    elif Path.check_dir_exists('~/.config/oh-my-zsh'):
        oh_my_zsh_path = '$HOME/.config/oh-my-zsh'
    elif Path.check_dir_exists('/usr/share/oh-my-zsh'):
        oh_my_zsh_path = '/usr/share/oh-my-zsh'

    if oh_my_zsh_path:
        return True
    else:
        Print.err('oh-my-zsh is not installed, cannot proceed...')
        # TODO: Option to install
        return False


def personalized_changes(file):
    if '.zshrc' in file:
        filedata = None
        with open(file, 'r') as f:
            filedata = f.read()
        filedata = filedata.replace('"$HOME/.config/oh-my-zsh"', f'"{oh_my_zsh_path}"')
        Print.err('Rewriting')
        with open(file, 'w') as f:
            f.write(filedata)


def init(symlink):
    # Get path to files/ floder (contains all dotfiles)
    files_dir = os.path.join(
        Path.get_parent(__file__), 'files')
    # Create optional backup
    make_backup(files_dir)
    # Go through all files
    for file in Path.get_all_files(files_dir):
        # Make personalized changes to files
        personalized_changes(file)
        # Set symlink position ($HOME/filepath)
        position = os.path.join(
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
