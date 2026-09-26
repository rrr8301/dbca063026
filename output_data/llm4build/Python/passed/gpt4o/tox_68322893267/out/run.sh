#!/bin/bash

# Activate virtual environment
source /opt/venv/bin/activate

# Install project dependencies
uv tool install --python-preference only-managed --python 3.12 tox@.

# Setup test suite
tox run -vv --notest --skip-missing-interpreters false -e 3.12

# Run test suite
tox run --skip-pkg-install -e 3.12