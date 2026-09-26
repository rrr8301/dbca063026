#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Run vendor script
if [ -f ./scripts/vendor.sh ]; then
    ./scripts/vendor.sh
else
    echo "vendor.sh script not found!"
    exit 1
fi

# Build the project
make loadable static

# Sync tests with uv
if command -v uv &> /dev/null; then
    uv sync --directory tests
else
    echo "uv command not found!"
    exit 1
fi

# Run tests
make test-loadable