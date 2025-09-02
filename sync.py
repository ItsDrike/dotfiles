#!/usr/bin/env python
from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
from collections.abc import Callable, Iterable, Iterator, Sequence
from enum import Enum, auto
from pathlib import Path
from typing import NamedTuple

try:
    import rich
except ImportError:
    print("rich not found (`pip install rich`), falling back to no colors", file=sys.stderr)
    rich = None

DOTROOTDIR = Path("./root")
ROOTDIR = Path("/")
DOTHOMEDIR = Path("./home")
HOMEDIR = Path(f"~{os.environ.get('SUDO_USER', os.getlogin())}")  # Make sure we use correct home even in sudo


def yes_no(prompt: str, default: bool | None = None) -> bool:
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
        if inp in {"n", "no"}:
            return False
        if inp == "" and default is not None:
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

            # In case the sys_file link uses an absolute path, make sure
            # it points to the same location, even if that location is a
            # symlink.
            dot_target = sys_file.parent.joinpath(dot_file.readlink()).absolute()
            sys_target = sys_file.parent.joinpath(sys_file.readlink()).absolute()
            if dot_target == sys_target:
                return DiffStatus.MATCH
            return DiffStatus.SYMLINK_DIFFERS
        return DiffStatus.EXPECTED_SYMLINK

    if sys_file.is_symlink():
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
        match diff.status:
            case DiffStatus.MATCH:
                status_str = f"[green]{_str_status}[/green]"
            case DiffStatus.PERMISSION_ERROR:
                status_str = f"[bold yellow]{_str_status}[/bold yellow]"
            case DiffStatus.NOT_FOUND:
                status_str = f"[bold orange_red1]{_str_status}[/bold orange_red1]"
            case _:
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
    PARTIAL_OVERWRITE = auto()
    SKIP = auto()

    @classmethod
    def pick(cls, file_path: Path, system_type: str | None, dotfile_type: str) -> FixChoice:
        if system_type is None:
            overwrite_system_prompt = f"Create non-existing {dotfile_type}"
            overwrite_dotfile_prompt = f"Delete dotfile {dotfile_type}"
        else:
            overwrite_system_prompt = f"Overwrite the system {system_type} with the dotfile {dotfile_type}"
            overwrite_dotfile_prompt = f"Overwrite the dotfile {dotfile_type} with the system {system_type}"

        options = [overwrite_system_prompt, overwrite_dotfile_prompt, "Skip this fix"]

        # With 2 files, partial overwrites are also a possibility
        partial_prompt = "Selectively apply partial overwrites to either file"
        if system_type == dotfile_type == "file":
            # Add the partial option before the skip option
            options.insert(-1, partial_prompt)

        answer = choice_input(f"How to fix {file_path}?", options)

        if answer == overwrite_system_prompt:
            return cls.OVERWRITE_SYSTEM
        if answer == overwrite_dotfile_prompt:
            return cls.OVERWRITE_DOTFILE
        if answer == partial_prompt:
            return cls.PARTIAL_OVERWRITE
        if answer == "Skip this fix":
            return cls.SKIP

        raise Exception("Invalid answer, this can't happen")


def _overwrite_file(source: Path, target: Path, partial: bool = False):
    """Overwrite content of `target` file/directory/symlink with `source` file/directory/symlink.

    If `partial` is True, `vimdiff` or `nvim -d` is opened for an interactive editor,
    where the user can selectively apply any changes to either file.
    """
    if not source.exists():
        raise ValueError(f"Can't overwrite target with non-existent source ({target=}, {source=})")

    if partial:
        if not target.exists():
            raise ValueError(f"Can't apply a partial patch with non-existent target ({target=})")

        if shutil.which("nvim") is not None:
            prog = ["nvim", "-d"]
        elif shutil.which("vim") is not None:
            prog = ["vimdiff"]
        else:
            raise ValueError("No diff tool installed, please install neovim or vim")

        subprocess.run([*prog, str(source), str(target)], check=True)  # noqa: S603
        return

    # Remove the target, if it already exists
    if target.exists():
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink()

    # Ensure parent dir exists for the target
    target.parent.mkdir(parents=True, exist_ok=True)

    # Copy the source to given target, preserving symlinks
    if source.is_dir():
        shutil.copytree(source, target, symlinks=True)
    else:
        shutil.copy(source, target, follow_symlinks=False)


def apply_fix(diff: FileDiff) -> None:
    """Ask the user how to fix the difference, and apply requested fix."""
    match diff.status:
        case DiffStatus.PERMISSION_ERROR:
            print("Skipping fix: insufficient permissions")
            return
        case DiffStatus.UNEXPECTED_DIRECTORY:
            _choice = FixChoice.pick(diff.sys_file, "directory", "file")
        case DiffStatus.UNEXPECTED_SYMLINK:
            _choice = FixChoice.pick(diff.sys_file, "symlink", "file")
        case DiffStatus.EXPECTED_SYMLINK:
            _choice = FixChoice.pick(diff.sys_file, "file/directory", "symlink")
        case DiffStatus.SYMLINK_DIFFERS:
            _choice = FixChoice.pick(diff.sys_file, "symlink", "symlink")
        case DiffStatus.NOT_FOUND:
            _choice = FixChoice.pick(diff.sys_file, None, "file")
        case DiffStatus.CONTENT_DIFFERS:
            _choice = FixChoice.pick(diff.sys_file, "file", "file")
        case status:
            raise Exception(f"Diff status {status!r} didn't match on any cases. This should never happen")

    partial = False
    match _choice:
        case FixChoice.SKIP:
            return
        case FixChoice.OVERWRITE_SYSTEM:
            source = diff.dot_file
            target = diff.sys_file
        case FixChoice.OVERWRITE_DOTFILE:
            source = diff.sys_file
            target = diff.dot_file
        case FixChoice.PARTIAL_OVERWRITE:
            # It doesn't really matter which is the target and which is source here
            # since the user will be given an interactive environment where they can
            # make changes to either file.
            source = diff.dot_file
            target = diff.sys_file
            partial = True
        case choice:
            raise Exception(f"Choice {choice!r} didn't match on any cases. This should never happen")

    try:
        _overwrite_file(source=source, target=target, partial=partial)
    except PermissionError:
        print("Fix failed: insufficient permissions")
        return


def show_diffs(diffs: Iterable[FileDiff], ask_show_diff: bool, apply_fix_prompt: bool) -> None:
    for diff in diffs:
        match diff.status:
            case DiffStatus.MATCH:
                continue
            case DiffStatus.CONTENT_DIFFERS:
                if ask_show_diff is False or yes_no(f"Show diff for {diff.sys_file}?"):
                    subprocess.run(  # noqa: PLW1510
                        ["git", "diff", str(diff.dot_file), str(diff.sys_file)],  # noqa: S607,S603
                    )
            case _:
                _str_status = diff.status.name.replace("_", " ")
                print(f"Skipping {diff.sys_file} diff for status: {_str_status}")

        if apply_fix_prompt:
            apply_fix(diff)
            print("---")


def exclude_fun(diff: FileDiff) -> bool:
    exclude_rules: list[Callable[[FileDiff], bool]] = [
        lambda d: d.status is DiffStatus.MATCH,
        lambda d: d.dot_file.name == ".gitkeep" and d.sys_file.parent.is_dir(),
        lambda d: Path("root/etc/opensnitchd/rules") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/eww") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/z.lua") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/local/src/Hyprland") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-you-should-use") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-syntax-highlighting") in d.rel_dot_file.parents,
        lambda d: Path("root/usr/share/zsh/site-functions/zsh-autosuggestions") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/zsh/.zgenom") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/tmux/plugins/tpm") in d.rel_dot_file.parents,
        lambda d: Path("home/.cache/zsh/history") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("home/.config/nomacs/Image Lounge.conf") == d.rel_dot_file
        and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("home/.config/pcmanfm/default/pcmanfm.conf") == d.rel_dot_file
        and d.status is DiffStatus.CONTENT_DIFFERS,
    ]

    return all(not exc_rule(diff) for exc_rule in exclude_rules)


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
