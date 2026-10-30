#!/bin/bash

# Run vendor script
./scripts/vendor.sh

# Build the project
make loadable static

# Sync tests with uv
# Ensure uv is installed and available in PATH
export PATH="$PATH:/usr/local/bin"  # Adjust this path if uv is installed elsewhere
uv sync --directory tests

# Run tests
make test-loadable