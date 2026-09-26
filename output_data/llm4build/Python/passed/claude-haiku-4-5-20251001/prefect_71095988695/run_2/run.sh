#!/bin/bash

set -e

# Start Redis server in the background
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

# Install project dependencies using uv
echo "Installing project dependencies..."
/root/.local/bin/uv sync --locked

# Run tests
echo "Running tests..."
/root/.local/bin/uv run pytest \
  tests/server/ \
  tests/events/server \
  --ignore=tests/server/database/ \
  --ignore=tests/server/orchestration/ \
  -m "not windows" \
  --numprocesses auto \
  --maxprocesses 6 \
  --dist worksteal \
  --disable-docker-image-builds \
  --exclude-service kubernetes \
  --exclude-service docker \
  --durations 26 \
  || TEST_FAILED=1

# Ensure all tests run even if some fail
if [ "$TEST_FAILED" = "1" ]; then
  echo "Some tests failed, but continuing to completion..."
  exit 1
fi

echo "All tests completed successfully!"
exit 0