import typing as t

from src.util.color import Color


class Print:
    def question(question: str, options: t.Optional[list] = None) -> None:
        """Print syntax for question with optional `options` to it"""
        text = [f"{Color.GREEN} // {question}{Color.RESET}"]
        if options:
            for option in options:
                text.append(f"{Color.GREEN}    # {options}{Color.RESET}")
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
