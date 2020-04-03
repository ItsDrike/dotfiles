#!/bin/python3
from util import Command


def get_256_color(color):
    '''Get color using tput (256-colors base)

    Arguments:
        color {str/int} -- color id

    Returns:
        color -- color prefix for strings
    '''
    return Command.get_output(f'tput setaf {color}')


def get_special_color(index):
    '''Get special colors using tput (like bold, etc..)

    Arguments:
        index {str} -- arguments following `tput` command

    Returns:
        color -- color prefix for strings
    '''
    return Command.get_output(f'tput {index}')


RED = get_256_color(196)
BLUE = get_256_color(51)
GREEN = get_256_color(46)
YELLOW = get_256_color(226)
GOLD = get_256_color(214)
GREY = get_256_color(238)

RESET = get_special_color('sgr0')
BOLD = get_special_color('bold')
