import typing as t

from src.util.color import Color


class Print:
    def question(question: str, options: t.Optional[list] = None) -> None:
        """Print syntax for question with optional `options` to it"""
        text = [f"{Color.GREEN} // {question}{Color.RESET}"]
        if options:
            for option in options:
                text.append(f"{Color.GREEN}    # {option}{Color.RESET}")
        print("\n".join(text))

    def action(action: str) -> None:
        """Print syntax for action"""
        print(f"{Color.GOLD} >> {action}{Color.RESET}")

    def err(text: str) -> None:
        """Print syntax for error"""
        print(f"{Color.RED}   !! {text}{Color.RESET}")

    def cancel(text: str) -> None:
        """Print syntax for cancellation"""
        print(f"{Color.GREY} >> {text}{Color.RESET}")

    def comment(text: str) -> None:
        """Print syntax for comments"""
        print(f"{Color.GREY} // {text}{Color.RESET}")

    def warning(text: str) -> None:
        """Print syntax for warnings"""
        print(f"{Color.YELLOW} ** {text}{Color.RESET}")


class Input:
    def yes_no(question: str) -> bool:
        """Ask a yes/no `question`, return True(y)/False(n)"""
        while True:
            Print.question(question)
            ans = input("   Y/N: ").lower()
            if ans == "y" or ans == "":
                return True
            elif ans == "n":
                return False
            else:
                Print.err("Invalid option (Y/N)")

    def multiple(question: str, options: t.List[str], abort: bool = False) -> int:
        """
        Ask `question` with multiple `options`
        Return index from options list as chosen option

        You can also specify `abort` which will add option `-1` for No/Cancel
        """
        num_options = [f"{index + 1}: {option}" for index, option in enumerate(options)]
        if abort:
            num_options.append("-1: No/Cancel")
        while True:
            Print.question(question, num_options)
            try:
                ans = int(input(f"   Choice (1-{len(options)}{'/-1' if abort else None}): "))
            except TypeError:
                Print.err(f"Invalid option, must be a number between 1-{len(options)}")
                continue

            if ans in range(len(options) + 1):
                return ans - 1
            else:
                Print.err(f"Invalid option, outside of the number range 1-{len(options)}")

    def text(text: str) -> str:
        Print.question(text)
        return input("  >>")
