import builtins
import readline
import sys
import threading

lock = threading.Lock()


def println(message: str) -> None:
    with lock:
        sys.stdout.write('\r\033[K')
        sys.stdout.write(f'{message}\n')

        sys.stdout.write(f'> {readline.get_line_buffer()}')
        sys.stdout.flush()


def input() -> str:
    with lock:
        sys.stdout.write('\r\033[K')
        sys.stdout.flush()

    return builtins.input('> ')
