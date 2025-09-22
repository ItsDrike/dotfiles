#!/usr/bin/env python3
# This entire thing is unnecessary post v3.13.0a3
# https://github.com/python/cpython/issues/73965

import os
import sys
import atexit
import readline
from pathlib import Path


def is_vanilla() -> bool:
    """Check whether this is a vanilla Python interpreter below 3.13."""
    return (
        not hasattr(__builtins__, "__IPYTHON__")
        and "bpython" not in sys.argv[0]
        and sys.version_info < (3, 13)
    )


def setup_history() -> None:
    """Read and write history from state file."""
    # Check PYTHON_HISTORY for future-compatibility with Python 3.13
    if history := os.environ.get("PYTHON_HISTORY"):
        history = Path(history)

    # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
    elif state_home := os.environ.get("XDG_STATE_HOME"):
        state_home = Path(state_home)
    else:
        state_home = Path.home() / ".local" / "state"

    history: Path = history or state_home / "python_history"

    # https://github.com/python/cpython/issues/105694
    if not history.is_file():
        # breaks on macos + python3 without this.
        readline.write_history_file(str(history))

    readline.read_history_file(history)
    atexit.register(readline.write_history_file, history)


if is_vanilla():
    setup_history()
