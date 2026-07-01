#!/usr/bin/env bash

set -e

export PATH="/root/.local/bin:$PATH"

# Print Python version
python3 --version

# Print uv version
uv --version

# Change to app directory
cd /app

# Create coverage directory
mkdir -p coverage

# Print pydantic version info
uv run python -c "import pydantic.version; print(pydantic.version.version_info())"

# Run tests
echo "Running tests..."
uv run coverage run -m pytest --durations=10 --parallel-threads 1

echo "FINAL_STATUS = SUCCESS"
