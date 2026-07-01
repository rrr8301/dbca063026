#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
uv sync --all-packages --group testing-extra --all-extras

# Run Python command to check pydantic version
uv run python -c "import pydantic.version; print(pydantic.version.version_info())"

# Create coverage directory
mkdir -p coverage

# Run tests
make test NUM_THREADS=1

# Note: Coverage files are not stored as artifacts in this local setup