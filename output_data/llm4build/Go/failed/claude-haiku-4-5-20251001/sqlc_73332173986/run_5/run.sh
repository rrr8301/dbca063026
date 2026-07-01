#!/bin/bash
set -e

# Navigate to the workspace (repository root)
cd /workspace

# Install gotestsum
echo "Installing gotestsum..."
go install gotest.tools/gotestsum@latest

# Install sqlc-gen-test
echo "Installing sqlc-gen-test..."
go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0

# Install test-json-process-plugin
echo "Installing test-json-process-plugin..."
go install ./scripts/test-json-process-plugin/

# Install project dependencies
echo "Installing project dependencies..."
CGO_ENABLED=0 go install ./...

# Build internal/endtoend testdata
echo "Building internal/endtoend testdata..."
cd /workspace/internal/endtoend/testdata
CGO_ENABLED=0 go build ./...

# Return to workspace root for database setup
cd /workspace

# Update apt cache before installing databases
echo "Updating package cache..."
apt-get update

# Install additional runtime dependencies for PostgreSQL binaries
echo "Installing additional PostgreSQL runtime dependencies..."
apt-get install -y --no-install-recommends \
    libreadline8 \
    libz1 \
    libssl3 \
    libossp-uuid16 \
    libc6 \
    libgcc-s1 \
    || true

# Install databases
echo "Installing databases..."
go run ./cmd/sqlc-test-setup install

# Start databases
echo "Starting databases..."
go run ./cmd/sqlc-test-setup start

# Run tests
echo "Running tests..."
export CI_SQLC_PROJECT_ID="${CI_SQLC_PROJECT_ID:-}"
export CI_SQLC_AUTH_TOKEN="${CI_SQLC_AUTH_TOKEN:-}"
export SQLC_AUTH_TOKEN="${SQLC_AUTH_TOKEN:-}"
export POSTGRESQL_SERVER_URI="postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable"
export MYSQL_SERVER_URI="root:mysecretpassword@tcp(127.0.0.1:3306)/mysql?multiStatements=true&parseTime=true"
export CGO_ENABLED=0

gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...

echo "Tests completed successfully!"