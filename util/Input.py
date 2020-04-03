#!/bin/python3
from util import Print


def yes_no(question):
    '''Generate question and wait for yes/no answer from user

    Arguments:
        question {str} -- question text

    Returns:
        bool -- question result (yes==true)
    '''
    Print.question(question)
    while True:
        ans = input('   Y/N: ')
        if ans.lower() == 'y' or ans == '':
            return True
        elif ans.lower() == 'n':
            return False
        else:
            Print.err('Invalid option (Y/N)')


def multiple(question, options):
    '''Generate question and wait for user to pick one of options specified

    Arguments:
        question {str} -- question text
        options {list} -- list of possible options (strings)

    Returns:
        str -- one of options
    '''
    def get_input_range(max):
        while True:
            inp = input(' ->')
            try:
                inp = int(inp)
                for n in range(0, max + 1):
                    if inp == n:
                        return inp
                        break
                else:
                    Print.err(f'Invalid input, range: 0-{max}')
            except ValueError:
                Print.err(f'Invalid input (must be number: 0-{max})')
                continue

    Print.question(question)

    Print.question_options('0: No/Cancel')
    for index, option in enumerate(options):
        Print.question_options(f'{index + 1}: {option}')

    answer = get_input_range(len(options))
    if answer != 0:
        return options[answer - 1]
    else:
        return False


def question(text):
    Print.question(text)
    return input('   >>')
