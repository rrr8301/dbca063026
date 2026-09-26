#!/bin/bash

# Activate Python environment
python3.12 -m venv .venv
source .venv/bin/activate

# Install project dependencies using uv
uv sync

# Run unit tests
export PYTHONUNBUFFERED=1
uv pip uninstall pydantic alembic sqlalchemy sqlmodel
uv run --no-sync pytest tests/units --cov --no-cov-on-fail --cov-report= --cov-fail-under=0
uv sync