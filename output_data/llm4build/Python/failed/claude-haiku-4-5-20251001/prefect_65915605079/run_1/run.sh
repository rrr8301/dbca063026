#!/bin/bash
set -e

# Activate uv environment
export PATH="/root/.cargo/bin:$PATH"

# Clone or use existing repo (repo is already copied in Dockerfile)
cd /workspace

# Install project dependencies using uv
echo "Installing dependencies with uv..."
uv sync --locked

# Start Redis container
echo "Starting Redis container..."
docker run \
  --name "redis" \
  --detach \
  --publish 6379:6379 \
  redis:latest

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
sleep 2
for i in {1..30}; do
  if docker exec redis redis-cli ping > /dev/null 2>&1; then
    echo "Redis is ready"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "Redis failed to start"
    exit 1
  fi
  sleep 1
done

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

# Check database container (informational, ignore errors)
echo "Checking for postgres container..."
docker container inspect postgres \
  && docker container logs postgres \
  || echo "Postgres container not found (expected)"

echo "Tests completed successfully"