#!/usr/bin/env bash

set -e

# Start Redis in the background
echo "Starting Redis server..."
redis-server --daemonize yes --port 6379 --loglevel warning

# Wait for Redis to be ready
for i in {1..30}; do
  if redis-cli ping > /dev/null 2>&1; then
    echo "Redis is ready"
    break
  fi
  echo "Waiting for Redis..."
  sleep 1
done

# Run linting
echo "Running linting..."
yarn lint || true

# Build
echo "Building..."
yarn build

# Run tests
echo "Running tests..."
yarn test

echo "FINAL_STATUS = SUCCESS"
