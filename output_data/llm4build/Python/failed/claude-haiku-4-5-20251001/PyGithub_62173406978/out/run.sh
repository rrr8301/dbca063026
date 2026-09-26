#!/bin/bash

set -e

# Print Python version for verification
echo "Python version:"
python --version

echo "Pip version:"
pip --version

echo "Tox version:"
tox --version

# Change to workspace directory
cd /workspace

# Run tox tests
echo "Running tox tests..."
tox || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed, but continuing to completion..."
    exit 1
fi

exit 0