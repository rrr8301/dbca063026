#!/bin/bash

# Create and activate Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
uv sync --all-packages --all-extras --group testing-extra

# Build the project
uv run --no-sync maturin develop --uv

# Freeze Python dependencies
uv pip freeze

# Run tests
uv run pytest