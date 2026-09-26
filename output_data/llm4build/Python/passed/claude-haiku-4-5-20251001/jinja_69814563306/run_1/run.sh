#!/bin/bash

set -e

# Add uv to PATH
export PATH="$HOME/.local/bin:$PATH"

# Verify Python version
echo "Python version:"
python --version

# Verify uv installation
echo "uv version:"
uv --version

# Install project dependencies using uv with locked dependencies
echo "Installing dependencies with uv..."
uv sync --locked

# Run tests using tox for Python 3.11
echo "Running tests with tox for Python 3.11..."
uv run --locked tox run -e py3.11

echo "All tests completed successfully!"