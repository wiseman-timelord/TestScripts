# keycheck.py

import curses

def main(stdscr):
    while True:
        c = stdscr.getch()
        stdscr.addstr(f'You pressed: {c} which is {chr(c)}\n')
        if c == ord('q'):
            break

curses.wrapper(main)