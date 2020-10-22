import os
import shutil
from datetime import datetime
from contextlib import suppress

from src.util.user import Print, Input


def _backup_file(backup_dir: str, subdir: str, file: str):
    """
    Backup given `file` in given `subdir`
    """
    origin_subdir = subdir.replace("home/", f"{os.environ['HOME']}/").replace("root/", "/")
    origin_path = os.path.join(origin_subdir, file)

    # Only backup files which exists in origin destination (real system destination)
    if os.path.exists(origin_path):
        backup_subdir = os.path.join(backup_dir, subdir)
        backup_path = os.path.join(backup_subdir, file)
        # Ensure directory existence in the new backup directory
        with suppress(FileExistsError):
            os.makedirs(backup_subdir)

        if file != "placeholder":
            Print.comment(f"Backing up {origin_path}")
            shutil.copyfile(origin_path, backup_path)


def make_backup() -> None:
    """
    Find all files which will be replaced and back them up.
    Files which doesn't exist in the real system destination
    will be ignored.
    """
    Print.action("Creating current dotfiles backup")
    time = str(datetime.now()).replace(" ", "--")
    backup_dir = os.path.join(os.getcwd(), "backup", time)
    os.makedirs(backup_dir)

    # backup files in `home` directory
    for subdir, _, files in os.walk("home"):
        for file in files:
            _backup_file(backup_dir, subdir, file)

    # backup files in `root` directory
    for subdir, _, files in os.walk("root"):
        for file in files:
            _backup_file(backup_dir, subdir, file)

    Print.action("Backup complete")


def install_dotfiles():
    if Input.yes_no("Do you want to backup current dotfiles? (Recommended)"):
        make_backup()


if __name__ == "__main__":
    install_dotfiles()
