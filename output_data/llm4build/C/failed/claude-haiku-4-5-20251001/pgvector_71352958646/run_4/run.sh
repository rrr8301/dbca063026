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

# Start PostgreSQL server
echo "Starting PostgreSQL server..."
sudo service postgresql start
sleep 2

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if sudo -u postgres psql -c "SELECT 1" > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        break
    fi
    echo "Attempt $i: Waiting for PostgreSQL..."
    sleep 1
done

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