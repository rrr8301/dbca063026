#!/usr/bin/env bash

set -e

export TOX_SKIP_MISSING_INTERPRETERS=False
export VIRTUALENV_SYSTEM_SITE_PACKAGES=0
export FORCE_COLOR=1
export PY_COLORS=1
export TERM=xterm-color
export MYPY_FORCE_COLOR=1
export MYPY_FORCE_TERMINAL_WIDTH=200
export PYTEST_ADDOPTS="--color=yes"

echo "PATH: $PATH"
echo "which python: $(which python)"
echo "python version: $(python -c 'import sys; print(sys.version)')"

cd /app

echo "Setting up tox environment..."
python -m tox run -e py --notest

echo "Running tests..."
python -m tox run -e py --skip-pkg-install -- -n 4

echo "FINAL_STATUS = SUCCESS"
