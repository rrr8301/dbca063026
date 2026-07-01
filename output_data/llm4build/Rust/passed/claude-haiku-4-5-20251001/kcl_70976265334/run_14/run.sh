#!/bin/bash
set -e

# Use the pre-activated venv Python
export PATH="/workspace/venv/bin:${PATH}"

# Verify Python and pip are from venv
echo "Python: $(which python3)"
echo "Pip: $(which pip)"
python3 --version

# Run code format check
echo "=== Running code format check ==="
cargo fmt --check

# Run clippy lint
echo "=== Running clippy lint ==="
make lint-all

# Run grammar tests
echo "=== Running grammar tests ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make
make test-grammar

# Run runtime tests
echo "=== Running runtime tests ==="
make test-runtime

# Run unit tests
echo "=== Running unit tests ==="
make test

echo "=== All tests completed successfully ==="