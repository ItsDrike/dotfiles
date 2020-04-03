#!/bin/python3
import os
import pathlib

from util import Command, Print

WORKING_FLODER = os.path.dirname(os.path.realpath(__file__))


def check_dir_exists(paths):
    '''Check for directory/ies existence

    Arguments:
        paths {str} -- single path or multiple paths separated by spaces (absolute paths)

    Returns:
        bool -- One of dirs exists/Single dir exists
    '''
    if type(paths) != str:
        paths = str(paths)
    paths = paths.split(' ')
    for dir_path in paths:
        dir_path = os.path.expanduser(dir_path)
        if os.path.isdir(dir_path):
            return True
            break
    else:
        return False


def check_file_exists(paths):
    '''Check for file/s existence

    Arguments:
        paths {str} -- single path or multiple paths separated by spaces (absolute paths)

    Returns:
        bool -- One of files exists/Single file exists
    '''
    if type(paths) != str:
        paths = str(paths)
    paths = paths.split(' ')
    for file_path in paths:
        file_path = os.path.expanduser(file_path)
        if os.path.isfile(file_path):
            return True
            break
    else:
        return False


def get_parent(file_path):
    '''Get Parent directory of specified file

    Arguments:
        file {str} -- path to file

    Returns:
        str -- directory to file
    '''
    return pathlib.Path(file_path).parent.absolute()


def get_all_files(dir_path):
    '''Get list of all files in specified directory (recursive)

    Arguments:
        dir_path {str/Path} -- path to starting directory

    Returns:
        list -- files found
    '''
    files_found = []
    for subdir, dirs, files in os.walk(dir_path):
        for file in files:
            files_found.append(os.path.join(subdir, file))
    return files_found


def get_all_dirs_and_files(dir_path):
    '''Get list of all files and directories in specified directory (recursive)

    Arguments:
        dir_path {str/Path} -- path to starting directory

    Returns:
        list, list-- files, dirs found
    '''
    files_found = []
    dirs_found = []
    for subdir, dirs, files in os.walk(dir_path):
        for file in files:
            files_found.append(os.path.join(subdir, file))
        for directory in dirs:
            dirs_found.append(os.path.join(subdir, directory))
    return files_found, dirs_found


def ensure_dirs(path, file_end=False, absolute_path=True):
    '''Ensure existence of directories (usually before creating files in it)

    Arguments:
        path {str} -- full path - will check every directory it contains

    Keyword Arguments:
        file_end {bool} -- does path end with file? (default: {False})
        absolute_path {bool} -- is path absolute? (default: {True})
    '''
    if not absolute_path:
        path = pathlib.Path(path).absolute()
    if check_file_exists(path) or file_end:
        path = get_parent(path)

    if not check_dir_exists(path):
        Command.execute(f'mkdir -p {path}')
        Print.comment(f'Creating directory {path}')


def get_home():
    '''Get home path

    Returns:
        str -- path to user home
    '''
    return os.environ['HOME']


def create_symlink(symlink_pointer, path):
    '''Create Symbolic link

    Arguments:
        symlink_pointer {str} -- path where symlink should be pointing
        path {str} -- path in which the symlink should be created
    '''
    ensure_dirs(path, file_end=True)
    Command.execute(f'ln -sf {symlink_pointer} {path}')
    Print.comment(f'Created symlink: {path} -> {symlink_pointer}')


def copy(path, copied_path):
    '''Create copy of specified file

    Arguments:
        path {str} -- path to original file
        copied_path {str} -- path to new file
    '''
    ensure_dirs(copied_path, file_end=True)
    Command.execute(f'cp {path} {copied_path}')
    Print.comment(f'Copied {path} to {copied_path}')


def join(*paths):
    '''Join paths together
    (This function is here to avoid re-importing os module in other scripts)

    Returns:
        str -- Joined paths
    '''
    return os.path.join(paths)
