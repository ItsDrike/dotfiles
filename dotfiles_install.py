from util import Path, Print, Install, Input
from datetime import datetime


class InstallationChecks:
    @staticmethod
    def installation_error(package):
        Print.err(f'Dotfiles installation cancelled - {package} not installed')
        raise Install.InstallationError(f'{package} not installed')

    @staticmethod
    def get_installation_path(standard_paths):
        dir_exists, path = Path.check_dir_exists(standard_paths)
        if dir_exists:
            path = path.replace('~', '$HOME')

        return dir_exists, path

    @staticmethod
    def install_package(package, standard_paths, status, use_aur=False):
        if not Install.package(
                package,
                f'default + (This is {status} for dotfiles to work)',
                aur=use_aur):
            return False, None
        else:
            installation_path = InstallationChecks.get_installation_path(
                standard_paths)

            if not installation_path:  # Package was not found in standard paths after installation
                Print.err(
                    f'Installation location of {package} has changed, please contact the developer'
                )
                return False, None
            else:
                return True, installation_path

    @staticmethod
    def check_zsh():
        if Install.check_not_installed('zsh'):
            if not Install.package(
                    'zsh',
                    'default + (This is REQUIRED shell for dotfiles to work)'):
                return False
        return True

    @staticmethod
    def check_oh_my_zsh():
        standard_paths = [
            '~/.oh-my-zsh', '~/oh-my-zsh', '~/ohmyzsh', '~/.config/oh-my-zsh',
            '/usr/share/oh-my-zsh'
        ]
        oh_my_zsh_path = InstallationChecks.get_installation_path(
            standard_paths)

        if oh_my_zsh_path[0]:  # Check if package was found in standard paths
            return True, oh_my_zsh_path[1]
        else:  # Package wasn't found, try to install it
            return InstallationChecks.install_package('oh-my-zsh',
                                                      standard_paths,
                                                      'REQUIRED zsh package',
                                                      use_aur=True)

    @staticmethod
    def check_zsh_highlight():
        standard_paths = [
            '/usr/share/zsh/plugins/zsh-syntax-highlighting',
            '/usr/share/zsh/zsh-syntax-highlighting',
            '/usr/share/zsh-syntax-highlighting'
        ]
        zsh_highlight_path = InstallationChecks.get_installation_path(
            standard_paths)

        if zsh_highlight_path[
                0]:  # Check if package was found in standard paths
            return True, zsh_highlight_path[1]
        else:  # Package wasn't found, try to install it
            return InstallationChecks.install_package(
                'zsh-syntax-highlighting', standard_paths,
                'RECOMMENDED zsh extension')


class PersonalizedChanges:
    @staticmethod
    def zshrc(dotfiles, file):
        with open(file, 'r') as f:
            filedata = f.read()

        # Set oh-my-zsh path
        filedata = filedata.replace('"$HOME/.config/oh-my-zsh"',
                                    f'"{dotfiles.oh_my_zsh_path}"')

        # Set path to zsh-color-highlighting
        if dotfiles.zsh_syntax_highlighting_installed:
            filedata = filedata.replace(
                '/usr/share/zsh/plugins/zsh-syntax-highlighting',
                dotfiles.zsh_syntax_highlighting_path)
        else:
            filedata = filedata.replace(
                '# Load zsh-syntax-highlighting (should be last)', '')
            filedata = filedata.replace(
                'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh',
                '')

        # TODO: XDG Standard following + dirs creation

        # Write changes
        with open(file, 'w') as f:
            f.write(filedata)
        return True

    @staticmethod
    def vimrc(file):
        if Input.yes_no(
                'Do you wish to use .vimrc (If you choose yes, please install Vundle or adjust .vimrc file (without Vundle multiple errors will occur)'
        ):
            # TODO: Vundle installation
            # TODO: XDG Standard following + dirs creation
            return True
        else:
            return False

    @staticmethod
    def gitconfig(file):
        with open(file, 'r') as f:
            filedata = f.read()

        # Replace git name for commits
        name = Input.question(
            'Please enter your git name (used only for commits - not github login)'
        )
        filedata = filedata.replace('name = koumakpet', f'name = {name}')

        # Replace git mail for commits
        mail = Input.question(
            'Please enter your git username (used only for commits - not github login)'
        )
        filedata = filedata.replace('email = koumakpet@protonmail.com',
                                    f'email = {mail}')
        return True


class Dotfiles:
    def __init__(self):
        self.backup_location = Path.join(Path.WORKING_FLODER, 'Backups')
        self.dotfiles_location = Path.join(Path.WORKING_FLODER, 'files')

    def start(self):
        Print.action('Installing dotfiles')

        # Check for necessary packages
        self.initial_checks()

        # Check backup
        if Input.yes_no(
                'Do you wish to create backup of your current dotfiles?'):
            self.make_backup()
        else:
            Print.warning(
                'Proceeding without backup, you will loose your current dotfiles settings'
            )

        # Symlinks or Files
        create_dotfiles = Input.multiple('Do you wish to create dotfiles?', [
            'symlinks (dotfiles/ dir will be required)',
            'files (dotfiles/ dir can be removed afterwards)'
        ])

        if create_dotfiles == 'symlinks':
            self.use_symlinks = True
        elif create_dotfiles == 'files':
            self.use_symlinks = False
        else:
            Print.err('Symlink creation aborted (canceled by user.)')
            return False

        self.create_dotfiles()

        Print.action('Dotfiles installation complete')
        if self.use_symlinks:
            Print.warning(
                'Do not remove this floder, all dotfiles depend on it')
            Print.warning(
                'If you wish to remove this floder, please select files instead of symlinks for dotfile creation'
            )
        else:
            Print.comment('This directory can now be removed')
        return True

    def initial_checks(self):
        if not InstallationChecks.check_zsh():
            InstallationChecks.installation_error('zsh')

        self.oh_my_zsh_installed, self.oh_my_zsh_path = InstallationChecks.check_oh_my_zsh(
        )
        if not self.oh_my_zsh_installed:
            InstallationChecks.installation_error('oh-my-zsh')

        self.zsh_syntax_highlighting_installed, self.zsh_syntax_highlighting_path = InstallationChecks.check_zsh_highlight(
        )

    def make_backup(self):
        Print.action('Creating current dotfiles backup')
        # time will be used as backup directory name
        cur_time = str(datetime.now()).replace(' ', '--')
        backup_dir = Path.join(self.backup_location, cur_time)
        Path.ensure_dirs(backup_dir)

        # Loop through every file in dotfiles_location
        for file in Path.get_all_files(self.dotfiles_location):
            # Remove dotfiles_location from file path
            file_blank = file.replace(f'{self.dotfiles_location}/', '')

            # Use path in home directory
            from_pos = Path.join(Path.get_home(), file_blank)
            # Use path in backup directory
            to_pos = Path.join(backup_dir, file_blank)

            # If file is in home directory, back it up
            if Path.check_file_exists(from_pos):
                Path.copy(from_pos, to_pos)

        Print.action('Backup complete')

    def personalized_changes(self, file):
        if '.zshrc' in file:
            return PersonalizedChanges.zshrc(self, file)
        elif 'vimrc' in file:
            return PersonalizedChanges.vimrc(file)
        elif '.gitconfig' in file:
            return PersonalizedChanges.gitconfig(file)
        else:
            return True

    def create_dotfiles(self):
        file_list = Path.get_all_files(self.dotfiles_location)
        for target_file in file_list:  # Loop through every file in dotfiles
            if not self.personalized_changes(target_file):
                continue

            # Remove dotfiles_location from file path
            file_blank = target_file.replace(f'{self.dotfiles_location}/', '')
            destination = Path.join(Path.get_home(), file_blank)

            if self.use_symlinks:
                Path.create_symlink(target_file, destination)
            else:
                Path.copy(target_file, destination)


if __name__ == "__main__":
    dotfiles = Dotfiles()
    dotfiles.start()
