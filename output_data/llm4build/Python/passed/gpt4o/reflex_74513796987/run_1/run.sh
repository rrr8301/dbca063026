#!/bin/bash

# Activate the virtual environment
source .venv/bin/activate

# Export necessary environment variables
export PYTHONUNBUFFERED=1

# Run unit tests without db dependencies
uv pip uninstall pydantic alembic sqlalchemy sqlmodel -y
uv run --no-sync pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0
uv sync

# Run unit tests
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests with Redis
export REFLEX_REDIS_URL=redis://localhost:6379
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests with Redis and OPLOCK_ENABLED
export REFLEX_OPLOCK_ENABLED=true
uv run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Generate coverage report
uv run coverage html