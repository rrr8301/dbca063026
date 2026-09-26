#!/bin/bash

# Activate Python 3.12 environment
source /usr/bin/python3.12

# Install project dependencies
uv tool install --no-managed-python --python 3.14 "tox>=4.45" --with tox-uv --with .

# Setup test suite
tox run -vvvv --notest --skip-missing-interpreters false

# Run test suite
tox run --skip-pkg-install