#!/bin/bash
set -e

# Start Redis service
echo "Starting Redis service..."
redis-server --daemonize yes --port 6379

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
for i in {1..30}; do
  if redis-cli ping > /dev/null 2>&1; then
    echo "Redis is ready"
    break
  fi
  echo "Waiting for Redis... ($i/30)"
  sleep 1
done

# Ensure uv is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Install uv if not already installed
if ! command -v uv &> /dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Run uv sync to install dependencies
echo "Installing project dependencies with uv sync..."
uv sync

# Export Python unbuffered mode
export PYTHONUNBUFFERED=1

# Run unit tests without db dependencies
echo "Running unit tests without db dependencies..."
uv pip uninstall -y pydantic alembic sqlalchemy sqlmodel || true
uv run --no-sync pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0 || TEST_FAILED=1
uv sync

# Run unit tests
echo "Running unit tests..."
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || TEST_FAILED=1

# Run unit tests with Redis
echo "Running unit tests with Redis..."
export REFLEX_REDIS_URL=redis://localhost:6379
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || TEST_FAILED=1

# Run unit tests with Redis and OPLOCK_ENABLED
echo "Running unit tests with Redis and OPLOCK_ENABLED..."
export REFLEX_OPLOCK_ENABLED=true
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || TEST_FAILED=1

# Generate coverage report
echo "Generating coverage report..."
uv run coverage html

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
  echo "Some tests failed, but all test suites were executed."
  exit 1
fi

echo "All tests completed successfully!"
exit 0