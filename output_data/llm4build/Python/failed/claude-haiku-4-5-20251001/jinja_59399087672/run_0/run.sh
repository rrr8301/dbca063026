#!/bin/bash
set -e

# Print Python version for debugging
echo "Python version:"
python --version

# Print uv version for debugging
echo "uv version:"
uv --version

# Install project dependencies using uv with locked dependencies
echo "Installing project dependencies..."
uv sync --locked

# Run tox tests for Python 3.12
echo "Running tox tests for Python 3.12..."
uv run --locked tox run -e py3.12

echo "All tests completed successfully!"