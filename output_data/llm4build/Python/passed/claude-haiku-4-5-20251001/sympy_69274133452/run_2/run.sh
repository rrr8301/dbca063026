#!/bin/bash

set -e

# Print Python version for verification
echo "Python version:"
python --version

# Install development dependencies from requirements-dev.txt
echo "Installing development dependencies..."
pip install --no-cache-dir -r requirements-dev.txt --break-system-packages

# Run pytest with parallel execution
echo "Running pytest with parallel execution..."
pytest -n auto

echo "All tests completed successfully!"