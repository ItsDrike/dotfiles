from util import Path, Print
from datetime import datetime


class Dotfiles:
    def __init__(self):
        self.backup_location = Path.join(Path.WORKING_FLODER, 'Backups')
        self.dotfiles_location = Path.join(Path.WORKING_FLODER, 'files')
        self.initial_checks()

    def initial_checks(self):
        pass

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
