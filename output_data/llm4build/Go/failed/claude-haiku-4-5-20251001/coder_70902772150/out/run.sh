#!/bin/bash
set -e

# Enable Go modules
export GO111MODULE=on

# Set test cache path
export TEST_CACHE_PATH="${HOME}/.cache/coderv2-test"
mkdir -p "$TEST_CACHE_PATH"

# Start PostgreSQL service
echo "Starting PostgreSQL 17..."
service postgresql start
sleep 2

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if pg_isready -h localhost -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        break
    fi
    echo "Attempt $i: PostgreSQL not ready yet, waiting..."
    sleep 1
done

# Create test database and user if needed
sudo -u postgres psql -c "CREATE USER coder WITH SUPERUSER PASSWORD 'coder';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE coder OWNER coder;" 2>/dev/null || true

# Normalize Terraform path for caching (from the workflow step)
echo "Normalizing Terraform path..."
mkdir -p "$RUNNER_TEMP/sym" 2>/dev/null || mkdir -p /tmp/sym
if [ -f scripts/normalize_path.sh ]; then
    source scripts/normalize_path.sh
    normalize_path_with_symlinks "${RUNNER_TEMP:-/tmp}/sym" "$(dirname "$(which terraform)")" || true
fi

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Run Go tests with PostgreSQL
# Parameters:
# - postgres-version: 17
# - test-parallelism-packages: 8
# - test-parallelism-tests: 8
# - test-count: 1 (on main branch) or empty (on PRs)
echo "Running Go tests with PostgreSQL 17..."

# Set test count based on branch (simulating github.ref logic)
TEST_COUNT=""
if [ "${GITHUB_REF}" == "refs/heads/main" ]; then
    TEST_COUNT="-count=1"
fi

# Run tests with PostgreSQL connection
# Assuming the test suite uses environment variables for database connection
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=coder
export POSTGRES_PASSWORD=coder
export POSTGRES_DB=coder

# Execute Go tests with specified parallelism
go test ./... \
    -parallel 8 \
    -timeout 25m \
    $TEST_COUNT \
    -v

echo "Tests completed successfully"