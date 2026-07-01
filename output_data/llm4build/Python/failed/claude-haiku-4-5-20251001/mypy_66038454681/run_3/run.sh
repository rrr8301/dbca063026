#!/bin/bash

set -e

# Set environment variables for colored output
export TOX_SKIP_MISSING_INTERPRETERS=False
export FORCE_COLOR=1
export PY_COLORS=1
export PYTHON_COLORS=0
export TERM=xterm-color
export MYPY_FORCE_COLOR=1
export MYPY_FORCE_TERMINAL_WIDTH=200
export PYTEST_ADDOPTS="--color=yes"

echo "=== Python Environment Info ==="
echo "PATH: $PATH"
echo "Python executable: $(which python)"
echo "Pip executable: $(which pip)"
python -c 'import sys; print("Python version:", sys.version)'
python -c 'import sysconfig; print("Debug build:", bool(sysconfig.get_config_var("Py_DEBUG")))'
python -c 'import os; print("CPU count:", os.cpu_count())'
python -c 'import os; print("Sched affinity:", len(getattr(os, "sched_getaffinity", lambda *args: [])(0)))'

echo ""
echo "=== Setting up tox environment ==="
tox run -e py --notest

echo ""
echo "=== Running tests ==="
tox run -e py --skip-pkg-install -- -n 4

echo ""
echo "=== Test suite completed ==="