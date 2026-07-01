#!/bin/bash
set -e

# Ensure uv is in PATH
export PATH="/root/.local/bin:$PATH"

# Run unit tests without db dependencies
echo "=== Running unit tests without db dependencies ==="
export PYTHONUNBUFFERED=1
uv pip uninstall pydantic alembic sqlalchemy sqlmodel --yes || true
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