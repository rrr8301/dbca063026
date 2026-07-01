#!/bin/bash

# Activate Python environment
python3.13 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -e .

# Install uv
uv tool install --python-preference only-managed --python 3.13 tox@.

# Setup test suite
tox run -vv --notest --skip-missing-interpreters false -e 3.13

# Run test suite
tox run --skip-pkg-install -e 3.13