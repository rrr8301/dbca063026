#!/bin/bash

set -e

# Start Redis server in background
echo "Starting Redis server..."
redis-server --daemonize yes --port 6379

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
for i in {1..30}; do
  if redis-cli ping > /dev/null 2>&1; then
    echo "Redis is ready!"
    break
  fi
  echo "Waiting for Redis... ($i/30)"
  sleep 1
done

# Verify Redis is running
if ! redis-cli ping > /dev/null 2>&1; then
  echo "ERROR: Redis failed to start"
  exit 1
fi

# Install dependencies
echo "Installing dependencies with yarn..."
yarn install --ignore-engines --frozen-lockfile --non-interactive

# Build the project
echo "Building project..."
yarn build

# Run tests for Bun
echo "Running Bun tests..."
yarn test:bun

echo "All tests completed!"