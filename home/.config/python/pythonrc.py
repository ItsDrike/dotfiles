import atexit
import os
import readline
from pathlib import Path

cache_xdg_dir = Path(os.environ.get("XDG_CACHE_HOME", str(Path("~/.cache"))))
cache_xdg_dir.mkdir(exist_ok=True, parents=True)

history_file = cache_xdg_dir.joinpath("python_history")

readline.read_history_file(history_file)


def write_history() -> None:
    readline.write_history_file(history_file)


atexit.register(write_history)
