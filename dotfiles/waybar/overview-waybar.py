#!/usr/bin/env python3
"""
Waybar visibility controller for Niri.

Shows waybar during overview and briefly on workspace switches.
Tracks visibility state explicitly to avoid toggle desync.
"""
from json import loads
from os import environ
from subprocess import run
from socket import AF_UNIX, socket, SHUT_WR
from threading import Timer
import sys

# State tracking (waybar starts hidden per config: start_hidden=true)
waybar_visible = False
overview_open = False
hide_timer = None
focused_workspace_id = None

SHOW_DURATION = 2.0


def set_waybar_visible(visible):
    global waybar_visible
    if visible != waybar_visible:
        run(["pkill", "-SIGUSR1", "waybar"], check=False)
        waybar_visible = visible


def cancel_hide_timer():
    global hide_timer
    if hide_timer is not None:
        hide_timer.cancel()
        hide_timer = None


def schedule_hide(seconds):
    global hide_timer
    cancel_hide_timer()

    def _hide():
        global hide_timer
        hide_timer = None
        if not overview_open:
            set_waybar_visible(False)

    hide_timer = Timer(seconds, _hide)
    hide_timer.daemon = True
    hide_timer.start()


def get_focused_workspace_id(workspaces):
    for ws in workspaces:
        if ws.get("is_focused"):
            return ws["id"]
    return None


def main():
    global overview_open, focused_workspace_id
    try:
        niri_socket = socket(AF_UNIX)
        niri_socket.connect(environ["NIRI_SOCKET"])
        file = niri_socket.makefile("rw")
        file.write('"EventStream"')
        file.flush()
        niri_socket.shutdown(SHUT_WR)

        for line in file:
            event = loads(line)

            if "OverviewOpenedOrClosed" in event:
                opened = event["OverviewOpenedOrClosed"]["is_open"]
                overview_open = opened
                if opened:
                    cancel_hide_timer()
                    set_waybar_visible(True)
                else:
                    schedule_hide(SHOW_DURATION)

            elif "WorkspacesChanged" in event:
                workspaces = event["WorkspacesChanged"]["workspaces"]
                new_focused = get_focused_workspace_id(workspaces)
                if focused_workspace_id is not None and new_focused != focused_workspace_id:
                    if not overview_open:
                        set_waybar_visible(True)
                        schedule_hide(SHOW_DURATION)
                focused_workspace_id = new_focused

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
