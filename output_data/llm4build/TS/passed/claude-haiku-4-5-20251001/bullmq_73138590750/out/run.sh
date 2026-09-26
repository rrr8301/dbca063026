#!/bin/bash

set -e

# Start Redis in the background
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

# Run ESLint
echo "Running ESLint..."
yarn lint || LINT_FAILED=1

# Build project
echo "Building project..."
yarn build || BUILD_FAILED=1

# Run tests
echo "Running tests..."
yarn test || TEST_FAILED=1

# Cleanup
redis-cli shutdown

# Report results
if [ "$LINT_FAILED" = "1" ]; then
  echo "ERROR: ESLint failed"
  exit 1
fi

if [ "$BUILD_FAILED" = "1" ]; then
  echo "ERROR: Build failed"
  exit 1
fi

if [ "$TEST_FAILED" = "1" ]; then
  echo "ERROR: Tests failed"
  exit 1
fi

echo "All checks passed!"
exit 0