#!/bin/bash
set -e

# Activate nvm
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Determine Go version from go.mod
GO_VERSION=$(grep "^go " go.mod | awk '{print $2}')
echo "Go version from go.mod: $GO_VERSION"

# Determine Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc 2>/dev/null || echo "18")
echo "Node.js version from .nvmrc: $NODE_VERSION"

# Install the correct Node.js version
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

# Verify installations
go version
node --version
npm --version

# Start PostgreSQL service
echo "Starting PostgreSQL..."
docker run -d \
  --name postgres \
  -e POSTGRES_DB=postgres \
  -e POSTGRES_PASSWORD=test \
  -e POSTGRES_USER=test \
  -p 5432:5432 \
  postgres:18
sleep 5

# Start MySQL service
echo "Starting MySQL..."
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=test \
  -p 3306:3306 \
  mysql:9.6
sleep 5

# Start CockroachDB service
echo "Starting CockroachDB..."
docker run -d \
  --name cockroach \
  -p 26257:26257 \
  cockroachdb/cockroach:latest-v25.4 \
  start-single-node --insecure || true
sleep 5

# Set database environment variables
export TEST_DATABASE_POSTGRESQL="postgres://test:test@localhost:5432/postgres?sslmode=disable"
export TEST_DATABASE_MYSQL="mysql://root:test@(localhost:3306)/mysql?parseTime=true&multiStatements=true"
export TEST_DATABASE_COCKROACHDB="cockroach://root@localhost:26257/defaultdb?sslmode=disable"

# Update apt
echo "Running apt-get update..."
apt-get update

# Install Node.js dependencies
echo "Installing npm dependencies..."
npm install

# Generate go.list for nancy
echo "Generating go.list..."
go list -json > go.list

# Run nancy for dependency checking
echo "Running nancy..."
nancy sleuth -o json go.list || true

# Run golangci-lint (skip if this is a tag)
if [ "$GITHUB_REF_TYPE" != "tag" ]; then
  echo "Running golangci-lint..."
  golangci-lint run --timeout 10m0s --new-from-rev=HEAD~1 || true
fi

# Build Kratos
echo "Building Kratos..."
make install

# Run tests with coverage
echo "Running tests with coverage..."
make test-coverage

echo "All tests completed!"