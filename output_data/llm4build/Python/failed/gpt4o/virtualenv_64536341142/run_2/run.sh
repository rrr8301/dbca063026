#!/bin/bash

# Activate Python 3.10 environment
source /venv/bin/activate

# Set TOXENV
export TOXENV="3.10"

# Fetch upstream tags
git fetch --force --tags https://github.com/pypa/virtualenv.git

# Setup test suite
tox run -vvvv --notest --skip-missing-interpreters false

# Run test suite
tox run --skip-pkg-install || true  # Ensure all tests run even if some fail