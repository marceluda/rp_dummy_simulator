#!/usr/bin/python3
from __future__ import print_function

from time import sleep
import mmap
import sys



def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def is_int(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

from hugo import osc,dm

if __name__ == '__main__':
    # Memory sectors to send

    if len(sys.argv)<2:
        dm.show()
    elif len(sys.argv)==2:
        if sys.argv[1] in dm.names():
            dm.show(sys.argv[1])
        else:
            print('reg not found')
    elif len(sys.argv)==3:
        if sys.argv[1] in dm.names() and is_int(sys.argv[2]):
            dm[sys.argv[1]].val(int(sys.argv[2]))
            dm.show(sys.argv[1])
    else:
        for i in sys.argv[1:]:
            if i in dm.names():
                dm.show(i)
