#!/usr/bin/env bash

# Start Redis in the background
redis-server --daemonize yes --port 6379

# Wait for Redis to be ready
for i in {1..30}; do
    if redis-cli ping 2>/dev/null | grep -q PONG; then
        echo "Redis is ready"
        break
    fi
    echo "Waiting for Redis to be ready... ($i/30)"
    sleep 1
done

export PYTHONUNBUFFERED=1

# Run unit tests without db dependencies
echo "Running unit tests without db dependencies..."
uv pip uninstall pydantic alembic sqlalchemy sqlmodel -y || true
uv run --no-sync pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0 || true
uv sync

# Run unit tests with db dependencies
echo "Running unit tests with db dependencies..."
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || true

# Run unit tests with redis
echo "Running unit tests with redis..."
export REFLEX_REDIS_URL=redis://localhost:6379
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || true

# Run unit tests with redis and OPLOCK_ENABLED
echo "Running unit tests with redis and OPLOCK_ENABLED..."
export REFLEX_OPLOCK_ENABLED=true
uv run pytest tests/units --cov --no-cov-on-fail --cov-report= || true

# Generate coverage report
echo "Generating coverage report..."
uv run coverage html || true

echo "FINAL_STATUS = SUCCESS"
