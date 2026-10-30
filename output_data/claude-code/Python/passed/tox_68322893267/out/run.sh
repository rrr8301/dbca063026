#!/usr/bin/env bash
set -e

export FORCE_COLOR=1

# Install tox@self with uv using Python 3.12
uv tool install --python-preference only-managed --python 3.12 tox@.

# Setup test suite
tox run -vv --notest --skip-missing-interpreters false -e 3.12

# Run test suite
export PYTEST_ADDOPTS="-vv --durations=20"
export DIFF_AGAINST=HEAD
export PYTEST_XDIST_AUTO_NUM_WORKERS=0

tox run --skip-pkg-install -e 3.12

# If we reach here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
