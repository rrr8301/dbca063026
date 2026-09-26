#!/bin/bash
set -e

# Clone or use existing repo (repo is already copied in Dockerfile)
cd /workspace

# Install project dependencies using uv
echo "Installing dependencies with uv..."
uv sync --locked

# Note: Redis should be started separately via Docker on the host
# (e.g., via GitHub Actions workflow step or docker-compose)
# This script assumes Redis is already running on localhost:6379

# Wait for Redis to be ready (if running)
echo "Waiting for Redis to be ready..."
if command -v redis-cli &> /dev/null; then
  for i in {1..30}; do
    if redis-cli ping > /dev/null 2>&1; then
      echo "Redis is ready"
      break
    fi
    if [ $i -eq 30 ]; then
      echo "Warning: Redis may not be ready, but continuing with tests..."
      break
    fi
    sleep 1
  done
else
  echo "redis-cli not found, skipping Redis readiness check"
fi

# Run tests
echo "Running pytest tests..."
uv run pytest tests/server/orchestration/ \
  -m "not windows" \
  --numprocesses auto \
  --maxprocesses 6 \
  --dist worksteal \
  --disable-docker-image-builds \
  --exclude-service kubernetes \
  --exclude-service docker \
  --durations 26

echo "Tests completed successfully"