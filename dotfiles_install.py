from util import Path, Print, Install
from datetime import datetime


class InstallationChecks:
    @staticmethod
    def installation_error(package):
        Print.err(f'Dotfiles installation cancelled - {package} not installed')
        raise Install.InstallationError(f'{package} not installed')

    @staticmethod
    def get_installation_path(standard_paths):
        dir_exists, path = Path.check_dir_exists(standard_paths)
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

        if oh_my_zsh_path:  # Check if package was found in standard paths
            return True, oh_my_zsh_path
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

        if zsh_highlight_path:  # Check if package was found in standard paths
            return True, zsh_highlight_path
        else:  # Package wasn't found, try to install it
            return InstallationChecks.install_package(
                'zsh-syntax-highlighting', standard_paths,
                'RECOMMENDED zsh extension')


class Dotfiles:
    def __init__(self):
        self.backup_location = Path.join(Path.WORKING_FLODER, 'Backups')
        self.dotfiles_location = Path.join(Path.WORKING_FLODER, 'files')

    def start(self):
        self.initial_checks()

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
        pass


if __name__ == "__main__":
    dotfiles = Dotfiles()
    dotfiles.start()
