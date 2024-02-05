import atexit
import os
import readline
from functools import partial
from pathlib import Path
from types import ModuleType

cache_xdg_dir = Path(
    os.environ.get("XDG_CACHE_HOME", str(Path("~/.cache").expanduser()))
)
cache_xdg_dir.mkdir(exist_ok=True, parents=True)

history_file = cache_xdg_dir.joinpath("python_history")
history_file.touch()

readline.read_history_file(history_file)


def write_history(readline: ModuleType, history_file: Path) -> None:
    """
    We need to get ``readline`` and ``history_file`` as arguments, as it
    seems they get garbage collected when the function is registered and
    the program ends, even though we refer to them here.
    """
    readline.write_history_file(history_file)


atexit.register(partial(write_history, readline, history_file))
