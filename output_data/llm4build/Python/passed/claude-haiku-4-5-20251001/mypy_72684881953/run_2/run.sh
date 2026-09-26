#!/bin/bash

set -e

# Set environment variables
export TOX_SKIP_MISSING_INTERPRETERS=False
export VIRTUALENV_SYSTEM_SITE_PACKAGES=0
export FORCE_COLOR=1
export PY_COLORS=1
export PYTHON_COLORS=0
export TERM=xterm-color
export MYPY_FORCE_COLOR=1
export MYPY_FORCE_TERMINAL_WIDTH=200
export PYTEST_ADDOPTS="--color=yes"

# Print debug information
echo "=== Debug Information ==="
echo "PATH: $PATH"
echo "which python: $(which python)"
echo "which pip: $(which pip)"
echo "python version: $(python -c 'import sys; print(sys.version)')"
echo "debug build: $(python -c 'import sysconfig; print(bool(sysconfig.get_config_var("Py_DEBUG")))')"
echo "os.cpu_count: $(python -c 'import os; print(os.cpu_count())')"
echo "os.sched_getaffinity: $(python -c 'import os; print(len(getattr(os, "sched_getaffinity", lambda *args: [])(0)))')"
echo "=== End Debug Information ==="

# Setup tox environment
echo "Setting up tox environment..."
tox run -e py --notest

# Run tests with 4 parallel workers
echo "Running tests..."
tox run -e py --skip-pkg-install -- -n 4

echo "Test suite completed successfully!"