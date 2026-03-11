#!/usr/bin/env python3
from json import loads
from os import environ
from subprocess import run
from socket import AF_UNIX, socket, SHUT_WR
import sys

def main():
    try:
        niri_socket = socket(AF_UNIX)
        niri_socket.connect(environ["NIRI_SOCKET"])
        file = niri_socket.makefile("rw")
        file.write('"EventStream"')
        file.flush()
        niri_socket.shutdown(SHUT_WR)

        for line in file:
            event = loads(line)
            if event.get("OverviewOpenedOrClosed"):
                # Toggle waybar visibility using SIGUSR1
                run(["pkill", "-SIGUSR1", "waybar"], check=False)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()