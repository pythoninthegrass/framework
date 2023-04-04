#!/usr/bin/env python3

# https://ipython.readthedocs.io/en/stable/interactive/reference.html#ipython-as-your-default-python-environment
# https://github.com/Textualize/rich#rich-repl

import os, IPython
from rich.jupyter import print

os.environ['PYTHONSTARTUP'] = ''  # Prevent running this again
IPython.start_ipython()
raise SystemExit
