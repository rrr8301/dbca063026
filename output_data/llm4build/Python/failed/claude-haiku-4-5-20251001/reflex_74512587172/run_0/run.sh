#!/bin/bash
set -e

# Start Redis in the background
redis-server --daemonize yes --port 6379

# Wait for Redis to be ready
for i in {1..30}; do
  if redis-cli ping > /dev/null 2>&1; then
    echo "Redis is ready"
    break
  fi
  echo "Waiting for Redis... ($i/30)"
  sleep 1
done

# Activate uv environment
export PATH="/root/.cargo/bin:$PATH"

# Run unit tests without db dependencies
echo "=== Running unit tests without db dependencies ==="
export PYTHONUNBUFFERED=1
uv pip uninstall -y pydantic alembic sqlalchemy sqlmodel || true
uv run --no-sync pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0
uv sync

# Run unit tests
echo "=== Running unit tests ==="
export PYTHONUNBUFFERED=1
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests w/ redis
echo "=== Running unit tests with Redis ==="
export PYTHONUNBUFFERED=1
export REFLEX_REDIS_URL=redis://localhost:6379
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests w/ redis and OPLOCK_ENABLED
echo "=== Running unit tests with Redis and OPLOCK_ENABLED ==="
export PYTHONUNBUFFERED=1
export REFLEX_REDIS_URL=redis://localhost:6379
export REFLEX_OPLOCK_ENABLED=true
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Generate coverage report
echo "=== Generating coverage report ==="
uv run coverage html

echo "=== All tests completed ==="