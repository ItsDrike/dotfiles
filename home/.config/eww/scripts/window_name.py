#!/usr/bin/env python3
"""This is a utility script for regex remaps on window names.

This is done in python, because of the complex regex logic, which would be pretty hard to
recreate in bash. This python script is expected to be called from the bash script controlling
the window names. Window name and class are obtained from piped stdin, to prevent having to
needlessly keep restarting this program, which takes a while due to the interpreter starting
overhead.
"""
import re
import json
import sys
from typing import Iterator, Optional


class RemapRule:
    __slots__ = ("name_pattern", "output_pattern", "class_pattern")

    def __init__(self, name_pattern: str, output_pattern: str, class_pattern: Optional[str] = None):
        self.name_pattern = re.compile(name_pattern)
        self.output_pattern = output_pattern
        self.class_pattern = re.compile(class_pattern) if class_pattern else None

    def apply(self, window_name: str, window_class: str) -> str:
        """Returns new name after this remap rule was applied."""
        if self.class_pattern is not None:
            if not self.class_pattern.fullmatch(window_class):
                # Rule doesn't apply, class mismatch, return original name
                return window_name

        res = self.name_pattern.fullmatch(window_name)
        if not res:
            # Rule doesn't apply, name mismatch, return original name
            return window_name

        # NOTE: This is potentially unsafe, since output_pattern might be say {0.__class__}, etc.
        # meaning this allows arbitrary attribute access, however it doesn't allow running functions
        # here. That said, code could still end up being run if there's some descriptor defined,
        # and generally I wouldn't trust this in production. However, this code is for my personal
        # use here, and all of the output patterns are hard-coded in this file, so in this case, it's
        # fine. But if you see this code and you'd like to use it in your production code, maybe don't
        return self.output_pattern.format(*res.groups())


# Rules will be applied in specified order
REMAP_RULES: list[RemapRule] = [
    RemapRule(r"", "", ""),
    RemapRule(r"(.*) — Mozilla Firefox", " {}", "firefox"),
    RemapRule(r"Mozilla Firefox", " Mozilla Firefox", "firefox"),
    RemapRule(r"Alacritty", " Alacritty", "Alacritty"),
    RemapRule(r"zsh;#toggleterm#1 - \(term:\/\/(.+)\/\/(\d+):(.+)\) - N?VIM", " Terminal: {0}"),
    RemapRule(r"(.+) \+ \((.+)\) - N?VIM", " {0} ({1}) [MODIFIED]"),
    RemapRule(r"(.+) \((.+)\) - N?VIM", " {0} ({1})"),
    RemapRule(r"(?:\[\d+\] )?\*?WebCord - (.+)", " {}", "WebCord"),
    RemapRule(r"(.+) - Discord", " {}", "discord"),
    RemapRule(r"(.+) - mpv", " {}", "mpv"),
    RemapRule(r"Stremio - (.+)", " Stremio - {}", "Stremio"),
    RemapRule(r"Spotify", " Spotify", "Spotify"),
    RemapRule(r"pulsemixer", " Pulsemixer"),
    RemapRule(r"(.*)", " {}", "Pcmanfm"),
]

MAX_LENGTH = 65


def iter_window() -> Iterator[tuple[str, str]]:
    """Listen for the window parameters from stdin/pipe, yields (window_name, window_class)."""
    for line in sys.stdin:
        line = line.removesuffix("\n")
        els = line.split(",", maxsplit=1)
        if len(els) != 2:
            raise ValueError(f"Expected 2 arguments from stdin line (name, class), but got {len(els)}")
        yield els[1], els[0]


def main() -> None:
    for window_name, window_class in iter_window():
        formatted_name = window_name
        for remap_rule in REMAP_RULES:
            formatted_name = remap_rule.apply(formatted_name, window_class)

        if len(formatted_name) > MAX_LENGTH:
            formatted_name = formatted_name[:MAX_LENGTH - 3] + "..."

        ret = json.dumps({"name": window_name, "class": window_class, "formatted_name": formatted_name})
        print(ret)
        sys.stdout.flush()


if __name__ == "__main__":
    main()
