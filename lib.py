#!/bin/python3
import subprocess


class Command:
    def execute(command):
        '''Execute bash command

        Arguments:
            command {str} -- full command

        Returns:
            int -- returncode
        '''
        command = command.split(' ')
        return subprocess.call(command)

    def get_output(command):
        '''Get standard output of command

        Arguments:
            command {str} -- full command

        Returns:
            str -- stdout
        '''
        command = command.split(' ')
        return subprocess.run(
            command, stderr=subprocess.STDOUT, stdout=subprocess.PIPE).stdout.decode('utf-8')

    def get_return_code(command):
        '''Get return code of command

        Arguments:
            command {str} -- full command

        Returns:
            int -- returncode
        '''
        command = command.split(' ')
        return subprocess.run(
            command, stderr=subprocess.STDOUT, stdout=subprocess.PIPE).returncode


class Color:
    '''Contains list of colors for printing'''
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


class Print:
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
        print(f'{Color.GREEN} # {options}{Color.RESET}')

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

    def warning(text):
        '''Print syntax for warnings

        Arguments:
            text {str} -- warn text to print
        '''
        print(f'{Color.YELLOW} ** {text}{Color.RESET}')


class Input:
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
            if ans.lower() == 'y':
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
                inp = input('   ->')
                try:
                    inp = int(inp)
                    for n in range(0, max + 1):
                        if inp == n:
                            return inp
                            break
                    else:
                        Print.err(f'Invalid input, range: 1-{max}')
                except ValueError:
                    Print.err(f'Invalid input (must be number: 1-{max})')
                    continue

        Print.question(question)

        options_str = '0: No/Cancel / '
        for index, option in enumerate(options):
            options_str += f'{index + 1}: {option} / '
        # Remove ending ' / '
        options_str = options_str[:-3]

        Print.question_options(options_str)
        answer = get_input_range(len(options))
        if answer != 0:
            return options[answer - 1]
        else:
            return False


class Install:
    def check_not_installed(package_name):
        '''Check if specified package is currently not installed

        Arguments:
            package_name {str/list} -- name of package/es to check

        Returns:
            bool -- is/are package/all packages not installed?
        '''
        if type(package_name) == str:
            out = Command.get_return_code(f'pacman -Qi {package_name}')
            if out == 1:
                # NOT INSTALLED
                return True
            else:
                # INSTALLED
                return False
        elif type(package_name) == list:
            for package in package_name:
                if not Install.check_not_installed(package):
                    break
            else:
                return True
            return False
        else:
            raise TypeError(
                'check_not_installed() only takes string or list inputs')

    def package(package_name, install_text='default', reinstall=False):
        '''Installation of package

        Arguments:
            package_name {str} -- name of package to be installed
            install_text {str} -- text presented to user before installing

        Returns:
            bool -- installed
        '''
        if Install.check_not_installed(package_name) or reinstall:
            if install_text == 'default':
                install_text = f'Do you wish to install {package_name}?'
            if install_text[:10] == 'default + ':
                install_text = f'Do you wish to install {package_name}? {install_text[10:]}'
            if Input.yes_no(install_text):
                Command.execute(f'sudo pacman -S {package_name}')
                return True
            else:
                Print.cancel('Skipping...')
                return False
        else:
            Print.cancel(f'{package_name} already installed')
            return False

    def multiple_packages(packages, install_text, options=False, reinstall=False):
        '''Installation of multiple packages

        Arguments:
            packages {list} -- list of packages to choose from
            install_text {str} -- text presented to user when picking which package to install
            options {list} -- list of options to choose from (must be in same order as packages)

        Returns:
            bool/str -- False if none / chosen package name
        '''
        if Install.check_not_installed(packages) or reinstall:
            if not options:
                options = packages
            choice = Input.multiple(f'{install_text}', options)
            if choice:
                for index, option in enumerate(options):
                    if choice == option:
                        Command.execute(f'sudo pacman -S {packages[index]}')
                        return packages[index]
            else:
                Print.cancel('Skipping...')
                return False
        else:
            for package in packages:
                if not Install.check_not_installed(package):
                    Print.cancel(f'{package} already installed')
            return False

    def upgrade_pacman():
        if Input.yes_no('Do you wish to Sync(S), refresh(y) and upgrade(u) pacman - Recommended?'):
            Command.execute('sudo pacman -Syu')
        else:
            Print.warning('Pacman upgrade cancelled.')
