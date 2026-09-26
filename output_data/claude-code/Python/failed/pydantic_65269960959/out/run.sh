#!/usr/bin/env bash
set -e

export PATH=/root/.cargo/bin:/root/.local/bin:$PATH

# Ensure environment is loaded
. /root/.local/bin/env

cd /app

# Build debug version of pydantic-core
uv run --no-sync maturin develop --uv --working-directory pydantic-core

# Show installed packages
uv pip freeze

# Run pytest
uv run pytest

echo "FINAL_STATUS = SUCCESS"
