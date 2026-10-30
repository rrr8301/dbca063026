#!/bin/bash

set -e

# Initialize ccache
ccache -M 500M
ccache -z

# Configure and build
echo "=== Building XNNPACK ==="
bash scripts/build-local.sh

# Run tests
echo "=== Running Tests ==="
cd build/local
ctest --output-on-failure --parallel $(nproc) || TEST_FAILED=1

# Print ccache stats
echo "=== CCache Statistics ==="
ccache -s

# Exit with failure if tests failed
if [ "${TEST_FAILED}" = "1" ]; then
    exit 1
fi

exit 0