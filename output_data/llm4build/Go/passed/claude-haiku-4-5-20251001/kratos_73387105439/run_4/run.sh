#!/bin/bash

set -e

# Set environment variables for database connections
export TEST_DATABASE_POSTGRESQL="postgres://test:test@localhost:5432/postgres?sslmode=disable"
export TEST_DATABASE_MYSQL="mysql://root:test@(localhost:3306)/mysql?parseTime=true&multiStatements=true"
export TEST_DATABASE_COCKROACHDB="cockroach://root@localhost:26257/defaultdb?sslmode=disable"

# Navigate to workspace
cd /workspace

# List Go dependencies (for reference)
echo "=== Go Dependencies ==="
go list -json > go.list

# Run nancy (dependency vulnerability check)
echo "=== Running nancy ==="
nancy sleuth -o json || true

# Build Kratos
echo "=== Building Kratos ==="
make install

# Run go tests with coverage
echo "=== Running Go Tests with Coverage ==="
make test-coverage

echo "=== All tests completed ==="