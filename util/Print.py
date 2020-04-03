#!/bin/python3
from util import Color


def question(question):
    '''Print syntax for question

    Arguments:
        question {str} -- text to print (question)
    '''
    print(f'{Color.GREEN} // {question}{Color.RESET}')


def question_options(options):
    '''Print syntax for options for question

    Arguments:
        options {str} -- options to print
    '''
    print(f'{Color.GREEN}    # {options}{Color.RESET}')


def action(action):
    '''Print syntax for actions

    Arguments:
        action {str} -- text to print
    '''
    print(f'{Color.GOLD} >> {action}{Color.RESET}')


def err(text):
    '''Print syntax for error

    Arguments:
        text {str} -- error text to print
    '''
    print(f'{Color.RED}   !! {text}{Color.RESET}')


def cancel(text):
    '''Print syntax for cancellation

    Arguments:
        text {str} -- text to print
    '''
    print(f'{Color.GREY} >> {text}{Color.RESET}')


def comment(text):
    '''Print syntax for comments

    Arguments:
        text {str} -- text to print
    '''
    print(f'{Color.GREY} // {text}{Color.RESET}')


def warning(text):
    '''Print syntax for warnings

    Arguments:
        text {str} -- warn text to print
    '''
    print(f'{Color.YELLOW} ** {text}{Color.RESET}')
