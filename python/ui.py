import os
from typing import Optional

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    CYAN = '\033[0;36m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'

class UI:
    @staticmethod
    def clear():
        os.system('clear' if os.name != 'nt' else 'cls')

    @staticmethod
    def header(title: str):
        print(f"\n{Colors.CYAN}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN} {title:^66}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*70}{Colors.RESET}\n")

    @staticmethod
    def pause():
        input(f"\n{Colors.YELLOW}Press [Enter] to continue...{Colors.RESET}")

    @staticmethod
    def confirm(message: str, default: bool = True) -> bool:
        prompt = f"{Colors.YELLOW}{message} [{'Y/n' if default else 'y/N'}]: {Colors.RESET}"
        response = input(prompt).strip().lower()
        if not response:
            return default
        return response == 'y'

    @staticmethod
    def success(message: str):
        print(f"{Colors.GREEN}[OK]{Colors.RESET} {message}")

    @staticmethod
    def error(message: str):
        print(f"{Colors.RED}[ERROR]{Colors.RESET} {message}")

    @staticmethod
    def warning(message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.RESET} {message}")

    @staticmethod
    def info(message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.RESET} {message}")