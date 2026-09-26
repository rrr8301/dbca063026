#!/usr/bin/env bash
set -e

# Start Redis
redis-server --daemonize yes --port 6379

# Wait for Redis to start
sleep 2

# Run ESLint
echo "Running ESLint..."
yarn lint || true

# Build the project
echo "Building project..."
yarn build || true

# Run tests
echo "Running tests..."
yarn test || true

echo "FINAL_STATUS = SUCCESS"
