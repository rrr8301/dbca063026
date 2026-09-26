#!/bin/bash

# Activate the virtual environment
source /opt/venv/bin/activate

# Install project dependencies using UV
uv sync --locked

# Run tests using the exact command from the YAML
uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "not integration and not client_process and not conformance" \
  --numprocesses auto --maxprocesses 4 --dist worksteal \
  tests