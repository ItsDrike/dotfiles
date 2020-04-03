#!/bin/python3
import os
import subprocess


def execute(command, use_os=False):
    '''Execute bash command

    Arguments:
        command {str} -- full command

    Keyword Arguments:
        os {bool} -- should the os module be used instead of subprocess (default: {False})

    Returns:
        int/bool -- returncode/True if os is used
    '''
    if not use_os:
        command = command.split(' ')
        return subprocess.call(command)
    else:
        os.system(command)
        return True


def get_output(command):
    '''Get standard output of command

    Arguments:
        command {str} -- full command

    Returns:
        str -- stdout
    '''
    command = command.split(' ')
    return subprocess.run(command,
                          stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE).stdout.decode('utf-8')


def get_return_code(command):
    '''Get return code of command

    Arguments:
        command {str} -- full command

    Returns:
        int -- returncode
    '''
    command = command.split(' ')
    return subprocess.run(command,
                          stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE).returncode
