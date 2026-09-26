#!/bin/bash
set -e

# Activate virtual environment
source /opt/venv/bin/activate

# Navigate to workspace
cd /workspace

# Run the build and test script
if [ -f ./test/ci-build.sh ]; then
    ./test/ci-build.sh
else
    echo "Error: test/ci-build.sh not found"
    exit 1
fi