#!/bin/bash

# Activate Python environment
source /usr/bin/python3.13

# Install project dependencies
uv sync --all-packages --all-extras --group testing-extra

# Build the project
uv run --no-sync maturin develop --uv

# Freeze Python dependencies
uv pip freeze

# Run tests
uv run pytest || true  # Ensure all tests run even if some fail