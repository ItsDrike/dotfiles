import subprocess


def execute(command) -> None:
    """Execute bash `command`, return the returncode (int)"""
    command = command.split(" ")
    subprocess.call(command)


def get_output(command) -> str:
    """Get standard output of `command`"""
    command = command.split(" ")
    return subprocess.run(
        command,
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE
    ).stdout.decode("utf-8")


def get_return_code(command) -> int:
    """get return code of `command` (int)"""
    command = command.split(" ")
    return subprocess.run(
        command,
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE
    ).returncode
