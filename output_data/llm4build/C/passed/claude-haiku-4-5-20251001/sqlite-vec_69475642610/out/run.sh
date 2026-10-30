#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Activate uv environment
export PATH="/root/.local/bin:${PATH}"

# Run vendor script
./scripts/vendor.sh

# Build loadable and static extensions
make loadable static

# Sync Python dependencies for tests
uv sync --directory tests

# Run tests
make test-loadable