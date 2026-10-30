#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

# Display Python version for debugging
echo "Python version:"
python --version

# Display pip version for debugging
echo "Pip version:"
pip --version

# Display tox version for debugging
echo "Tox version:"
tox --version || echo "Tox not yet installed"

# Install tox if not already installed
echo "Installing tox..."
pip install --upgrade pip==25.3
pip install tox

# Run unit tests with tox for Python 3.11
echo "Running unit tests with tox..."
tox -e ci-py311 -- -v --color=yes

echo "Test execution completed."