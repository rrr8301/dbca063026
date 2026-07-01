#!/bin/bash
set -e

# Install dependencies using uv with locked resolution
echo "Installing dependencies with uv..."
uv sync --locked

# Run unit tests using pytest
echo "Running unit tests..."
uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "not integration and not client_process and not conformance" \
  --numprocesses auto \
  --maxprocesses 4 \
  --dist worksteal \
  tests

echo "Tests completed successfully!"