#!/bin/bash

set -e

# Ensure uv is available
export PATH="/root/.local/bin:$PATH"

# Install project dependencies with test extras
echo "Installing project dependencies..."
uv pip install --system -e ".[test]"

# Run tests
echo "Running tests..."
python -m xonsh run-tests.xsh test -- --timeout=240

echo "Tests completed successfully!"