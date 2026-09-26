#!/bin/bash

# Activate the virtual environment
source .venv/bin/activate

# Export necessary environment variables
export PYTHONUNBUFFERED=1

# Check if pyproject.toml has the required version field
if ! grep -q '\[tool.poetry.version\]' pyproject.toml && ! grep -q '\[project.version\]' pyproject.toml; then
  echo "Warning: pyproject.toml must contain either [tool.poetry.version] or [project.version]."
  # Optionally, you can add a default version or handle this case differently
  # exit 1
fi

# Run unit tests without db dependencies
poetry run pip uninstall pydantic alembic sqlalchemy sqlmodel -y
poetry run pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0

# Run unit tests
poetry run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests with Redis
export REFLEX_REDIS_URL=redis://localhost:6379
poetry run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Run unit tests with Redis and OPLOCK_ENABLED
export REFLEX_OPLOCK_ENABLED=true
poetry run pytest tests/units --cov --no-cov-on-fail --cov-report=

# Generate coverage report
poetry run coverage html