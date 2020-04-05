from util import Path, Print, Install, Input
from datetime import datetime


class InstallChecks:
    @staticmethod
    def installation_error(package):
        Print.err(f'Dotfiles installation cancelled - {package} not installed')
        raise Install.InstallationError(f'{package} not installed')

    @staticmethod
    def get_installation_path(standard_paths, file_end=False):
        if file_end:
            path_exists, path = Path.check_file_exists(standard_paths)
            print(f'Installation path -> {path_exists}, {path}')
        else:
            path_exists, path = Path.check_dir_exists(standard_paths)

        return path

    @staticmethod
    def _make_install_text(status):
        return f'default + (This is {status} for dotfiles to work)'

    @staticmethod
    def zsh():
        if Install.check_not_installed('zsh'):
            if not Install.package(
                    'zsh',
                    'default + (This is REQUIRED shell for dotfiles to work)'):
                InstallChecks.installation_error('zsh')

    @staticmethod
    def oh_my_zsh(dotfiles):
        standard_paths = [
            '~/.oh-my-zsh', '~/oh-my-zsh', '~/ohmyzsh', '~/.config/oh-my-zsh',
            '/usr/share/oh-my-zsh'
        ]

        oh_my_zsh_path = InstallChecks.get_installation_path(standard_paths)

        # Check if package was found in standard paths
        if oh_my_zsh_path:
            dotfiles.oh_my_zsh = True
            dotfiles.oh_my_zsh_path = oh_my_zsh_path
        # Package wasn't found, try to install it
        else:
            install_text = InstallChecks._make_install_text(
                'REQUIRED zsh package')
            dotfiles.oh_my_zsh = Install.package('oh-my-zsh',
                                                 install_text,
                                                 aur=True)
            dotfiles.oh_my_zsh_path = InstallChecks.get_installation_path(
                standard_paths)

        if not dotfiles.oh_my_zsh:
            InstallChecks.installation_error('oh-my-zsh')

    @staticmethod
    def zsh_highlight(dotfiles):
        standard_paths = [
            '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh',
            '/usr/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh',
            '/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
        ]
        zsh_highlight_path = InstallChecks.get_installation_path(
            standard_paths, file_end=True)

        # Check if package was found in standard paths
        if zsh_highlight_path:
            dotfiles.zsh_highlight = True
            dotfiles.zsh_highlight_path = zsh_highlight_path
        # Package wasn't found, try to install it
        else:
            install_text = InstallChecks._make_install_text(
                'RECOMMENDED zsh extension')

            dotfiles.zsh_highlight = Install.package('zsh-syntax-highlighting',
                                                     install_text,
                                                     aur=False)
            dotfiles.zsh_highlight_path = InstallChecks.get_installation_path(
                standard_paths, file_end=True)

        if not dotfiles.zsh_highlight:
            Print.comment('Proceeding without zsh-syntax-highlighting')

    @staticmethod
    def vim_vundle(dotfiles, installation_path='~/.vim/bundle/Vundle.vim'):
        standard_paths = [
            '~/.vim/bundle/Vundle.vim', '~/.local/share/vim/bundle/Vundle.vim'
        ]

        vim_vundle_path = InstallChecks.get_installation_path(standard_paths)
        # Check if package was found in standard paths
        if vim_vundle_path:
            dotfiles.vim_vundle = True
            dotfiles.vim_vundle_path = vim_vundle_path
        # Package wasn't found, try to install it
        else:
            install_text = InstallChecks._make_install_text(
                'RECOMMENDED Vim Package Manager')
            dotfiles.vim_vundle = Install.git_install(
                'https://github.com/VundleVim/Vundle.vim.git',
                installation_path, install_text)
            if dotfiles.vim_vundle:
                dotfiles.vim_vundle_path = installation_path
            else:
                dotfiles.vim_vundle_path = None

        if not dotfiles.vim_vundle:
            Print.comment('Proceeding without zsh-syntax-highlighting')


class PersonalizedChanges:
    @staticmethod
    def zshrc(dotfiles, file):
        with open(file, 'r') as f:
            filedata = f.read()

        # Set oh-my-zsh path
        filedata = filedata.replace('"$HOME/.config/oh-my-zsh"',
                                    f'"{dotfiles.oh_my_zsh_path}"')

        # Set zsh-color-highlighting
        InstallChecks.zsh_highlight(dotfiles)
        if dotfiles.zsh_highlight:
            filedata = filedata.replace(
                '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh',
                dotfiles.zsh_highlight_path)
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
    def vimrc(dotfiles, file):
        if Input.yes_no(
                'Do you wish to follow XDG Standard for vim (.vim floder in .local/share/vim instead of home floder)'
        ):
            # Ensure XDG Directories
            Path.ensure_dirs('~/.local/share/vim/bundle')
            Path.ensure_dirs('~/.local/share/vim/swap')
            Path.ensure_dirs('~/.local/share/vim/undo')
            Path.ensure_dirs('~/.local/share/vim/backup')

            InstallChecks.vim_vundle(dotfiles,
                                     '~/.local/share/vim/bundle/Vundle.vim')
        else:
            # TODO: Change vimrc not to follow XDG
            InstallChecks.vim_vundle(dotfiles)
            Print.warning(
                'vim will produce multiple errors, please adjust paths not to use XDG Standard'
            )

        if not dotfiles.vim_vundle:
            if Input.yes_no(
                    'Do you wish to proceed without Vundle (.vimrc will produce multiple errors without Vundle )'
            ):
                return True
            else:
                return False
        return True

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
        InstallChecks.zsh()
        InstallChecks.oh_my_zsh(self)

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
            if Path.check_file_exists(from_pos)[0]:
                Path.copy(from_pos, to_pos)

        Print.action('Backup complete')

    def personalized_changes(self, file):
        if '.zshrc' in file:
            return PersonalizedChanges.zshrc(self, file)
        elif 'vimrc' in file:
            return PersonalizedChanges.vimrc(self, file)
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
