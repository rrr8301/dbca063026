#!/bin/bash
set -e

# Add uv to PATH
export PATH="/root/.cargo/bin:$PATH"

# Set test-specific environment variables
export PYTEST_ADDOPTS="-vv --durations=20"
export DIFF_AGAINST="HEAD"
export PYTEST_XDIST_AUTO_NUM_WORKERS=0

# Install tox@self using uv with Python 3.13
uv tool install --python-preference only-managed --python 3.13 tox@.

# Setup test suite (install dependencies, prepare environment)
tox run -vv --notest --skip-missing-interpreters false -e 3.13

# Run test suite
tox run --skip-pkg-install -e 3.13