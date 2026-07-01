#!/bin/bash
set -e

# Activate uv environment
export PATH="/root/.cargo/bin:$PATH"

# Setup test suite (install dependencies without running tests)
echo "Setting up test suite..."
tox run -vv --notest --skip-missing-interpreters false -e 3.12

# Run test suite
echo "Running test suite..."
tox run --skip-pkg-install -e 3.12