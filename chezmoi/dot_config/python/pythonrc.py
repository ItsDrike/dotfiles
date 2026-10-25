# This file should be pointed to by the $PYTHONSTARTUP environment variable.
# It will be run every time the Python interpreter starts in interactive mode.
#
# I use this file to configure the location of Python's interactive shell
# history file, as I don't like it polluting my $HOME directory.
#
# This script is only necessary for Python 3.4 through 3.12. Python 3.4
# introduced automatic history handling / storing for the interactive shell,
# while Python 3.13 introduced the $PYTHON_HISTORY environment variable, which
# can be used to configure the history file directly. Between these versions,
# Python would always have used the ~/.python_history path for this file.
#
# I additionally skip loading this hook for IPython and bpython interactive
# sessions, as those already have their own history handling separate from
# Python's native one.
#
# Refs:
#
# - Python 3.4 introduced history for interactive shells:
#   <https://docs.python.org/3/whatsnew/3.4.html#sys>
# - Python 3.13 later introduced the $PYTHON_HISTORY variable:
#   <https://github.com/python/cpython/issues/73965>
import sys


def configure_history() -> None:
    """Override the shell history file path for Python 3.4 through 3.12."""

    # The sys.__interactivehook__ is automatically injected by the site.py
    # module for interactive CPython sessions, and would normally run after
    # $PYTHONSTARTUP. By default, this hook then sets up the python history
    # file handling, completion and other interactive behavior. We delete it to
    # prevent it from running and set up our own logic with a cleaner history
    # path. If this hook wasn't present at all, it means nothing in Python
    # would otherwise set up history handling, so we should exit early too
    # instead of forcing history handling.
    if not hasattr(sys, "__interactivehook__"):
        return

    del sys.__interactivehook__

    # The readline module is technically optional, and CPython can be compiled
    # without it. The default interactive hook also has this check.
    try:
        import readline
    except ImportError:
        return

    import atexit
    import os
    from pathlib import Path

    python_history = Path(
        os.environ.get("PYTHON_HISTORY")
        or Path(os.environ.get("XDG_STATE_HOME") or "~/.local/state") / "python_history"
    ).expanduser()

    if not python_history.is_file():
        print(
            "Creating python histfile: {}".format(python_history),
            flush=True,
            file=sys.stderr,
        )
        python_history.parent.mkdir(parents=True, exist_ok=True)
        python_history.touch(mode=0o666, exist_ok=False)

        # Breaks on macos + python3 without this:
        # <https://github.com/python/cpython/issues/105694>
        readline.write_history_file(str(python_history))

    # Load the history from the existing file
    readline.read_history_file(str(python_history))

    # Make sure we automatically write the history at the exit of the program
    atexit.register(readline.write_history_file, str(python_history))

    # rlcompleter injects the complete method into readline at import time by
    # calling `readline.set_completer`. We want this injection to happen here,
    # as the default interactive hook also handles it, and injects the
    # completion bindings after.
    try:
        import rlcompleter  # noqa: F401
    except ImportError:
        return

    # Set up the tab auto-completion binding (replicates the logic from the
    # default interactive hook exactly).
    readline_doc = getattr(readline, "__doc__", "")

    if readline_doc is not None and "libedit" in readline_doc:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

    # Finally, the default interactive hook which we deleted also runs the
    # `read_init_file`. This function loads an optional ~/.inputrc or
    # equivalent libedit configurations (e.g. .editrc on macOS). This file
    # might contain things like keybindings, editing mode, completion behavior,
    # case sensitivity, etc. We call it ourselves to again replicate the
    # behavior we deleted.
    try:
        readline.read_init_file()
    except OSError:
        pass


if (
    (3, 4) <= sys.version_info < (3, 13)
    and "bpython" not in sys.modules
    and not hasattr(__builtins__, "__IPYTHON__")
):
    configure_history()


del configure_history
