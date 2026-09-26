#!/bin/bash

# Activate the Python 3.12 virtual environment
source /opt/venv/bin/activate

# Ensure the correct Python version is used
export UV_PYTHON_DOWNLOADS=never

# Install project dependencies
uv tool install --no-managed-python --python 3.14 "tox>=4.45" --with tox-uv --with .

# Setup test suite
tox run -e py312 -vvvv --notest --skip-missing-interpreters false

# Run test suite
tox run -e py312 --skip-pkg-install