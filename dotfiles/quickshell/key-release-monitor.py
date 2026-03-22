#!/usr/bin/env python3
"""Wait for Tab or Super key release via evdev, then print 'released' and exit."""
import struct, os, sys, glob, select

EVENT_SIZE = struct.calcsize('llHHi')
EV_KEY = 1
KEY_RELEASE = 0
WATCH_KEYS = frozenset({15, 125, 126})  # KEY_TAB, KEY_LEFTMETA, KEY_RIGHTMETA

def find_keyboards():
    result = []
    for path in sorted(glob.glob('/dev/input/event*')):
        try:
            name = os.path.basename(path)
            with open(f'/sys/class/input/{name}/device/capabilities/ev') as f:
                caps = int(f.read().strip(), 16)
                if caps & 0x2:
                    result.append(path)
        except (IOError, ValueError):
            continue
    return result

def main():
    keyboards = find_keyboards()
    if not keyboards:
        sys.exit(1)

    fds = []
    poll = select.poll()
    for kb in keyboards:
        try:
            fd = os.open(kb, os.O_RDONLY)
            fds.append(fd)
            poll.register(fd, select.POLLIN)
        except OSError:
            continue

    if not fds:
        sys.exit(1)

    try:
        while True:
            for fd, _ in poll.poll():
                data = os.read(fd, EVENT_SIZE * 64)
                for i in range(0, len(data) - EVENT_SIZE + 1, EVENT_SIZE):
                    _, _, ev_type, ev_code, ev_value = struct.unpack(
                        'llHHi', data[i:i + EVENT_SIZE]
                    )
                    if ev_type == EV_KEY and ev_value == KEY_RELEASE and ev_code in WATCH_KEYS:
                        print("released", flush=True)
                        return
    finally:
        for fd in fds:
            os.close(fd)

if __name__ == '__main__':
    main()
