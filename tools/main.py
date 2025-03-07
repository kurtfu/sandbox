#!/usr/bin/python3

import argparse
import atexit
import logging
import os
import readline
import socket
import textwrap
import threading

import cli


class Service:
    def __init__(self,
                 port: int,
                 name: str = os.path.splitext(os.path.basename(__file__))[0]):
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
            cmd, args = (cli.input().split(maxsplit=1) + ['', ''])[:2]

            if cmd == '':
                continue

            if cmd in self.commands:
                self.commands[cmd](args)
            else:
                cli.println(f'error: invalid command \'{cmd}\'')

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
            cli.println(f'error: invalid help topic \'{topic}\'')
            return

        cli.println(textwrap.dedent(manuals[topic]))

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

    def process(self, message: str) -> None:
        cli.println(message)


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument('port', type=int,
                        metavar='<port>',
                        help='TCP port for client connection')

    args = parser.parse_args()

    service = Service(args.port)
    service.run()


if __name__ == '__main__':
    main()
