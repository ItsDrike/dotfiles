#!/usr/bin/env python
from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
from collections.abc import Iterable, Iterator, Sequence
from enum import Enum, auto
from pathlib import Path
from typing import NamedTuple, Optional


try:
    import rich
except ImportError:
    print("rich not found (`pip install rich`), falling back to no colors", file=sys.stderr)
    rich = None

DOTROOTDIR = Path("./root")
ROOTDIR = Path("/")
DOTHOMEDIR = Path("./home")
HOMEDIR = Path(f"~{os.environ.get('SUDO_USER', os.getlogin())}")  # Make sure we use correct home even in sudo


def yes_no(prompt: str, default: Optional[bool] = None) -> bool:
    """Get a yes/no answer to given prompt by the user."""
    if default is None:
        prompt += " [y/n]: "
    elif default is True:
        prompt += "[Y/n]: "
    elif default is False:
        prompt += "[y/N]: "
    else:
        raise ValueError("Invalid default value")

    while True:
        inp = input(prompt).lower()
        if inp in {"y", "yes"}:
            return True
        elif inp in {"n", "no"}:
            return False
        elif inp == "" and default is not None:
            return default


def int_input(msg: str) -> int:
    """Get a valid integer input from the user."""
    while True:
        x = input(msg)
        try:
            return int(x)
        except ValueError:
            print("Invalid input, expected a number.")


def choice_input(msg: str, choices: Sequence[str]) -> str:
    """Get one of given choices based on a valid user input."""
    print(f"{msg}")
    for index, choice in enumerate(choices, start=1):
        print(f"{index}: {choice}")
    x = int_input("Enter your choice: ")
    if x < 1 or x > len(choices):
        print("Invalid choice! Try again")
        return choice_input(msg, choices)
    return choices[x - 1]


class DiffStatus(Enum):
    NOT_FOUND = auto()
    PERMISSION_ERROR = auto()
    MATCH = auto()
    EXPECTED_SYMLINK = auto()
    UNEXPECTED_SYMLINK = auto()
    CONTENT_DIFFERS = auto()
    SYMLINK_DIFFERS = auto()
    UNEXPECTED_DIRECTORY = auto()


class FileDiff(NamedTuple):
    dot_file: Path
    sys_file: Path
    status: DiffStatus

    def __repr__(self) -> str:
        dot_file = str(self.rel_dot_file)
        sys_file = str(self.sys_file)
        status = self.status.name
        return f"FileDiff({dot_file=}, {sys_file=}, {status=})"

    @property
    def rel_dot_file(self) -> Path:
        """Returns path to a dot_file relative to workdir."""
        return self.dot_file.relative_to(Path.cwd())


def iter_dir(directory: Path) -> Iterator[Path]:
    """Recursively iterate over given directory and yield all files in it."""
    for subpath in directory.iterdir():
        if subpath.is_file() or subpath.is_symlink():
            yield subpath
        else:
            yield from iter_dir(subpath)


def file_sum(file: Path) -> str:
    """Compute SHA-256 hash sum of given file."""
    sha256_hash = hashlib.sha256()
    with file.open("rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def compare_files(dot_file: Path, sys_file: Path) -> DiffStatus:
    """Compare two files returning their diff status."""
    try:
        if not sys_file.exists():
            return DiffStatus.NOT_FOUND
    except PermissionError:
        return DiffStatus.PERMISSION_ERROR

    if dot_file.is_symlink():
        if sys_file.is_symlink():
            if dot_file.readlink() == sys_file.readlink():
                return DiffStatus.MATCH
            else:
                # In case the sys_file link uses an absolute path, make sure
                # it points to the same location, even if that location is a
                # symlink.
                dot_target = sys_file.parent.joinpath(dot_file.readlink()).absolute()
                sys_target = sys_file.parent.joinpath(sys_file.readlink()).absolute()
                if dot_target == sys_target:
                    return DiffStatus.MATCH
                return DiffStatus.SYMLINK_DIFFERS
        return DiffStatus.EXPECTED_SYMLINK
    elif sys_file.is_symlink():
        return DiffStatus.UNEXPECTED_SYMLINK

    if sys_file.is_dir():
        return DiffStatus.UNEXPECTED_DIRECTORY

    try:
        if file_sum(dot_file) == file_sum(sys_file):
            return DiffStatus.MATCH
    except PermissionError:
        return DiffStatus.PERMISSION_ERROR

    return DiffStatus.CONTENT_DIFFERS


def iter_pairs() -> Iterator[tuple[Path, Path]]:
    """Go through all files in the dotfiles directories and match them to system paths.

    Yields tuples of (dotfile file path, matching system path)
    """
    for dot_file in iter_dir(DOTHOMEDIR):
        real_file = Path(HOMEDIR, *dot_file.parts[1:])
        yield dot_file.expanduser().absolute(), real_file.expanduser().absolute()

    for dot_file in iter_dir(DOTROOTDIR):
        real_file = Path(ROOTDIR, *dot_file.parts[1:])
        yield dot_file.expanduser().absolute(), real_file.expanduser().absolute()


def iter_diffs() -> Iterator[FileDiff]:
    """Go through all files and compute their diffs."""
    for dot_file, sys_file in iter_pairs():
        diff_status = compare_files(dot_file, sys_file)
        yield FileDiff(dot_file, sys_file, diff_status)


def print_report(diffs: Iterable[FileDiff]) -> None:
    """Pretty print the individual diff statuses."""
    # Exhause the iterable, and ensure we work on a copy
    diffs = list(diffs)

    # Sort by DiffStatus, with MATCH entries being first
    diffs.sort(key=lambda v: (v.status is not DiffStatus.MATCH, v.status.name))

    if rich is None:
        for diff in diffs:
            print(f"{diff.status.name}   ->    {diff.sys_file}")
        return

    from rich.table import Table
    table = Table()
    table.add_column("Status")
    table.add_column("System file", style="magenta")
    table.add_column("Dotfile file", style="magenta")

    for diff in diffs:
        _str_status = diff.status.name.replace("_", " ")
        if diff.status is DiffStatus.MATCH:
            status_str = (f"[green]{_str_status}[/green]")
        elif diff.status is DiffStatus.PERMISSION_ERROR:
            status_str = f"[bold yellow]{_str_status}[/bold yellow]"
        elif diff.status is DiffStatus.NOT_FOUND:
            status_str = f"[bold orange_red1]{_str_status}[/bold orange_red1]"
        else:
            status_str = f"[bold red]{_str_status}[/bold red]"

        try:
            # Unexpand home (/home/xyz/foo -> ~/foo)
            sys_file = Path("~") / diff.sys_file.relative_to(Path.home())
        except ValueError:  # File not in home
            sys_file = diff.sys_file

        sys_file = str(sys_file)
        dot_file = "./" + str(diff.rel_dot_file)
        table.add_row(status_str, sys_file, dot_file)

    rich.print(table)


class FixChoice(Enum):
    OVERWRITE_SYSTEM = auto()
    OVERWRITE_DOTFILE = auto()
    SKIP = auto()

    @classmethod
    def pick(cls, file_path: Path, system_type: Optional[str], dotfile_type: str) -> FixChoice:
        if system_type is None:
            overwrite_system_prompt = f"Create non-existing {dotfile_type}"
            overwrite_dotfile_prompt = f"Delete dotfile {dotfile_type}"
        else:
            overwrite_system_prompt = f"Overwrite the system {system_type} with the dotfile {dotfile_type}"
            overwrite_dotfile_prompt = f"Overwrite the dotfile {dotfile_type} with the system {system_type}"
        answer = choice_input(
            f"How to fix {file_path}?",
            [overwrite_system_prompt, overwrite_dotfile_prompt, "Skip this fix"],
        )

        if answer == overwrite_system_prompt:
            return cls.OVERWRITE_SYSTEM
        elif answer == overwrite_dotfile_prompt:
            return cls.OVERWRITE_DOTFILE
        elif answer == "Skip this fix":
            return cls.SKIP

        raise Exception("This can't happen (just here for typing.NoReturn)")


def apply_fix(diff: FileDiff) -> None:
    if diff.status is DiffStatus.PERMISSION_ERROR:
        print("Skipping fix: insufficient permissions")

    elif diff.status is DiffStatus.UNEXPECTED_DIRECTORY:
        _choice = FixChoice.pick(diff.sys_file, "directory", "file")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            shutil.rmtree(diff.sys_file)
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            diff.dot_file.unlink()
            shutil.copytree(diff.sys_file, diff.dot_file, symlinks=True)

    elif diff.status is DiffStatus.UNEXPECTED_SYMLINK:
        _choice = FixChoice.pick(diff.sys_file, "symlink", "file")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            diff.sys_file.unlink()
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            diff.dot_file.unlink()
            shutil.copy(diff.sys_file, diff.dot_file, follow_symlinks=False)

    elif diff.status is DiffStatus.EXPECTED_SYMLINK:
        _choice = FixChoice.pick(diff.sys_file, "file", "symlink")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            diff.sys_file.unlink()
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            diff.dot_file.unlink()
            shutil.copy(diff.sys_file, diff.dot_file, follow_symlinks=False)

    elif diff.status is DiffStatus.SYMLINK_DIFFERS:
        _choice = FixChoice.pick(diff.sys_file, "symlink", "file")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            diff.sys_file.unlink()
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            diff.dot_file.unlink()
            shutil.copy(diff.sys_file, diff.dot_file, follow_symlinks=False)

    elif diff.status is DiffStatus.NOT_FOUND:
        _choice = FixChoice.pick(diff.sys_file, None, "file")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            diff.dot_file.unlink()

    elif diff.status is DiffStatus.CONTENT_DIFFERS:
        _choice = FixChoice.pick(diff.sys_file, "file", "file")
        if _choice is FixChoice.SKIP:
            return
        elif _choice is FixChoice.OVERWRITE_SYSTEM:
            shutil.copy(diff.dot_file, diff.sys_file, follow_symlinks=False)
        elif _choice is FixChoice.OVERWRITE_DOTFILE:
            shutil.copy(diff.sys_file, diff.dot_file, follow_symlinks=False)


def show_diffs(diffs: Iterable[FileDiff], ask_show_diff: bool, apply_fix_prompt: bool) -> None:
    for diff in diffs:
        if diff.status is DiffStatus.MATCH:
            continue

        if diff.status is DiffStatus.CONTENT_DIFFERS:
            if ask_show_diff is False or yes_no(f"Show diff for {diff.sys_file}?"):
                subprocess.run(["git", "diff", str(diff.sys_file), str(diff.dot_file)])
        else:
            _str_status = diff.status.name.replace("_", " ")
            print(f"Skipping {diff.sys_file} diff for status: {_str_status}")

        if apply_fix_prompt:
            apply_fix(diff)
            print("---")


def exclude_fun(diff: FileDiff) -> bool:
    EXCLUDE_RULES = [
        lambda d: d.status is DiffStatus.MATCH,
        lambda d: d.dot_file.name == ".keep" and d.sys_file.parent.is_dir(),
        lambda d: Path("root/etc/opensnitchd/rules") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/eww") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/z.lua") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/Hyprland") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-you-should-use") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-syntax-highlighting") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-autosuggestions") in d.rel_dot_file.parents,
        lambda d: Path("home/.cache/zsh/history") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("home/.config/nomacs/Image Lounge.conf") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("home/.config/pcmanfm/default/pcmanfm.conf") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
    ]

    for exc_rule in EXCLUDE_RULES:
        if exc_rule(diff):
            return False
    return True


def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="sync.py",
        description="Compare the differences between system file and dotfile file versions",
    )
    parser.add_argument(
        "-E",
        "--no-apply-excludes",
        help="Don't apply exclude rules (some files are expected to be modified, use if you want to see these too)",
        action="store_true",
    )
    parser.add_argument(
        "-R",
        "--no-show-report",
        help="Don't show the full report of all files, and their diff status in the beginning",
        action="store_true",
    )
    exc_grp = parser.add_mutually_exclusive_group()
    exc_grp.add_argument(
        "-d",
        "--show-diffs",
        help="Show file diffs comparing the versions (using git diff)",
        action="store_true",
        default=None,
    )
    exc_grp.add_argument(
        "-D",
        "--no-show-diffs",
        help="Don't show file diffs comparing the versions",
        dest="show_diffs",
        action="store_false",
    )
    parser.add_argument(
        "-A",
        "--no-ask-each-diff",
        help="Don't ask whether to show a diff or not for each modified file (can be annoying for many files)",
        action="store_true",
    )
    parser.add_argument(
        "-f",
        "--apply-fixes",
        help=(
            "Asks whether to overwrite the system file with the dotfile version (or vice-versa)."
            " This option can only be used with --show-diffs"
        ),
        action="store_true",
        default=None,
    )

    ns = parser.parse_args()

    if ns.no_ask_each_diff and not ns.show_diffs:
        parser.error("-A/--no-ask-each-diff only makes sense with -d/--show-diffs")

    if ns.apply_fixes and not ns.show_diffs:
        parser.error("-f/--apply-fixes only makes sense with -d/--show-diffs")

    return ns


def main() -> None:
    ns = get_args()

    diffs = iter_diffs()
    if not ns.no_apply_excludes:
        diffs = filter(exclude_fun, diffs)
    diffs = list(diffs)

    if not ns.no_show_report:
        print_report(diffs)

    if ns.show_diffs is True or ns.show_diffs is None and yes_no("Show diffs for modified files?"):
        if ns.apply_fixes is None:
            apply_fixes = yes_no("Apply fixes?")
        else:
            apply_fixes = ns.apply_fixes
        show_diffs(diffs, ask_show_diff=not ns.no_ask_each_diff, apply_fix_prompt=apply_fixes)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nStopped...", file=sys.stderr)
