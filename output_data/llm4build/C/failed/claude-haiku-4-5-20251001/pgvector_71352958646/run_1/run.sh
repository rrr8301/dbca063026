#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Export PG_CONFIG path
export PG_CONFIG=$(which pg_config)

# Set custom PostgreSQL compilation flags
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

# Build the extension
echo "Building pgvector..."
make

# Install the extension
echo "Installing pgvector..."
sudo --preserve-env=PG_CONFIG make install

# Run regression tests
echo "Running regression tests..."
make installcheck || TEST_FAILED=1

# Display regression diffs if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Test failures detected. Displaying regression.diffs:"
    if [ -f regression.diffs ]; then
        cat regression.diffs
    fi
    exit 1
fi

echo "All tests passed!"