def is_vanilla() -> bool:
    import sys

    return not hasattr(__builtins__, "__IPYTHON__") and "bpython" not in sys.argv[0]


def setup_history():
    import os
    import atexit
    import readline
    from pathlib import Path

    if state_home := os.environ.get("XDG_STATE_HOME"):
        state_home = Path(state_home)
    else:
        state_home = Path.home() / ".local" / "state"

    history: Path = state_home / "python_history"

    # https://github.com/python/cpython/issues/105694
    if not history.is_file():
        # breaks on macos + python3 without this.
        readline.write_history_file(str(history))

    readline.read_history_file(str(history))
    atexit.register(readline.write_history_file, str(history))


if is_vanilla():
    setup_history()
