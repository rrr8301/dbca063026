#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

# Display Python version for debugging
echo "Python version:"
python --version

echo "Pip version:"
pip --version

echo "Tox version:"
tox --version

# Run tox tests for Python 3.10
echo "Running tox tests for Python 3.10..."
tox -e ci-py310 -- -v --color=yes

echo "All tests completed successfully!"