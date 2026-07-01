#!/bin/bash

# Activate Python virtual environment
source /app/venv/bin/activate

# Install project dependencies
pip install uv

# Sync and install project dependencies
uv sync --all-packages --all-extras --group testing-extra

# Build the project
uv run --no-sync maturin develop --uv

# Freeze Python dependencies
uv pip freeze

# Run tests
uv run pytest