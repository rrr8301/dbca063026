#!/bin/bash
set -e

# Activate uv environment
export PATH="/root/.local/bin:$PATH"

# Setup test suite (install dependencies without running tests)
echo "Setting up test suite..."
tox run -vv --notest --skip-missing-interpreters false -e py312

# Run test suite
echo "Running test suite..."
tox run --skip-pkg-install -e py312