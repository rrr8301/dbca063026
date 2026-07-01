#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout@v6 with fetch-depth: 0)
if [ ! -d "/workspace/repo" ]; then
    git clone --fetch-depth=0 https://github.com/mpmath/mpmath.git /workspace/repo
fi

cd /workspace/repo

# Upgrade pip and setuptools
python -m pip install --upgrade setuptools pip

# Install project with extras: develop, gmpy2, gmp, ci
python -m pip install --upgrade ".[develop,gmpy2,gmp,ci]"

# Run pytest with parallel execution (-n auto)
# Set PYTEST_ADDOPTS environment variable as per job config
export PYTEST_ADDOPTS="-n auto"

# Run all tests, ensuring all test cases execute even if some fail
pytest || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0