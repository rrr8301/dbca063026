#!/usr/bin/env bash
set -e

# Start Docker daemon in the background
dockerd --storage-driver=vfs &
DOCKER_PID=$!

# Wait for Docker to be ready
echo "Waiting for Docker daemon to start..."
for i in {1..30}; do
  if docker ps &>/dev/null; then
    echo "Docker is ready"
    break
  fi
  echo "Docker startup attempt $i/30..."
  sleep 1
done

if ! docker ps &>/dev/null; then
  echo "Failed to start Docker daemon"
  kill $DOCKER_PID 2>/dev/null || true
  exit 1
fi

# Run the tests
echo "Running tests..."
if make test COVERAGE_DIR=/tmp/coverage; then
  echo "Tests completed successfully"
  FINAL_STATUS="SUCCESS"
else
  echo "Tests failed or encountered errors"
  FINAL_STATUS="FAIL"
fi

# Kill Docker daemon
kill $DOCKER_PID 2>/dev/null || true
wait $DOCKER_PID 2>/dev/null || true

echo "FINAL_STATUS = $FINAL_STATUS"
