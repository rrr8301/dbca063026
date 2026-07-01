#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies using uv
echo "Installing dependencies..."
uv sync --all-packages --all-extras --group testing-extra

# Build pydantic-core with maturin
echo "Building pydantic-core..."
cd pydantic-core
uv run --no-sync maturin develop --uv
cd ..

# Show installed packages
echo "Installed packages:"
uv pip freeze

# Run tests
echo "Running tests..."
uv run pytest

echo "All tests completed successfully!"