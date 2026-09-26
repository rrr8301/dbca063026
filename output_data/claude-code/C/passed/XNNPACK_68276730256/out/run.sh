#!/usr/bin/env bash

set -e

cd /app

# Configure ccache limit
ccache -M 500M
ccache -z

# Configure and build
bash scripts/build-local.sh

# Run tests
cd build/local
ctest --output-on-failure --parallel $(nproc)
cd /app

# Print ccache stats
ccache -s

echo "FINAL_STATUS = SUCCESS"
