#!/bin/bash

set -e

# Print environment info
echo "Python version:"
python --version
echo ""
echo "Pip version:"
pip --version
echo ""
echo "Tox version:"
tox --version
echo ""

# Run tox tests
echo "Running tox tests..."
tox

echo ""
echo "Tests completed successfully!"