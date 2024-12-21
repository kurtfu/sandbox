#!/usr/bin/python3

import atexit
import logging
import os
import readline
import socket
import sys
import textwrap
import threading


class Service:
    def __init__(self,
                 name: str = os.path.splitext(os.path.basename(__file__))[0],
                 port: int = 8080) -> None:
        self.active = False

        self.acceptor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        self.acceptor.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.acceptor.settimeout(1)

        self.acceptor.bind(('0.0.0.0', port))
        self.acceptor.listen()

        history_file = os.path.dirname(os.path.realpath(__file__))
        history_file = os.path.join(history_file, '.' + name + '_history')

        log_file = os.path.join('logs', name + '.log')

        os.makedirs(os.path.dirname(log_file), exist_ok=True)

        logging.basicConfig(
            filename=log_file,
            filemode='w',
            format='%(asctime)s.%(msecs)03d %(filename)s:%(lineno)-4d %(levelname)-8s %(message)s',
            datefmt='%H:%M:%S',
            level='INFO',
        )

        try:
            readline.read_history_file(history_file)
        except FileNotFoundError:
            pass

        atexit.register(readline.write_history_file, history_file)

        self.lock = threading.Lock()

        self.commands = {
            'help': self.help,
            'quit': self.quit,
        }

    def run(self) -> None:
        logging.info('Initializing service...')

        self.active = True

        self.listener = threading.Thread(target=self.listen)
        self.listener.start()

        while self.active:
            cmd, args = (self.input().split(maxsplit=1) + ['', ''])[:2]

            if cmd == '':
                continue

            if cmd in self.commands:
                self.commands[cmd](args)
            else:
                self.println(f'error: invalid command \'{cmd}\'')

    def quit(self, _: str) -> None:
        logging.info('Terminating service...')

        self.active = False

        try:
            self.acceptor.close()

            self.connection.shutdown(socket.SHUT_RD)
            self.connection.close()
        except:
            pass

        self.listener.join()

        logging.info('Service terminated')

    def help(self, topic: str) -> None:
        manuals = {
            '': f'''
                Usage: {os.path.basename(__file__)} <command> [arguments]

                Commands:
                    quit  Terminates the service and exits

                For More Help:
                    help <command> Shows detailed help for <command>
            ''',
        }

        if topic not in manuals:
            self.println(f'error: invalid help topic \'{topic}\'')
            return

        self.println(textwrap.dedent(manuals[topic]))

    def listen(self) -> None:
        logging.info('Waiting for connection...')

        connected = False

        while self.active and not connected:
            try:
                self.connection.close()
                self.connection, _ = self.acceptor.accept()

                connected = True
                logging.info('Connection established')
            except:
                continue

            while connected:
                message = self.recv()

                if message is not None:
                    self.process(message)
                else:
                    connected = False
                    logging.warning('Connection lost')

    def process(self, message: str) -> None:
        self.println(message)

    def send(self, message: str) -> None:
        try:
            self.connection.send(message.encode())
        except:
            pass

    def recv(self, length: int = 1024) -> str | None:
        try:
            message = self.connection.recv(length)
            return None if message == b'' else message.decode()
        except:
            return None

    def println(self, message: str) -> None:
        with self.lock:
            sys.stdout.write('\r\033[K')
            sys.stdout.write(f'{message}\n')

            sys.stdout.write(f'> {readline.get_line_buffer()}')
            sys.stdout.flush()

    def input(self) -> str:
        with self.lock:
            sys.stdout.write('\r\033[K')
            sys.stdout.flush()

        return input('> ')


def main():
    service = Service()
    service.run()


if __name__ == '__main__':
    main()
