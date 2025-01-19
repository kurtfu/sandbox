import builtins
import readline
import sys
import threading

__lock = threading.Lock()
__is_waiting_input = False


def println(message: str) -> None:
    with __lock:
        sys.stdout.write('\r\033[K')
        sys.stdout.write(f'{message}\n')

        if __is_waiting_input:
            sys.stdout.write(f'> {readline.get_line_buffer()}')
            sys.stdout.flush()


def input() -> str:
    global __is_waiting_input

    with __lock:
        __is_waiting_input = True

        sys.stdout.write('\r\033[K')
        sys.stdout.flush()

    prompt = builtins.input('> ')

    with __lock:
        __is_waiting_input = False

    return prompt
