#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies
uv pip install --system .

# Run tests
set +e  # Continue on errors
nox --session "tests-3.12" -- --full-trace
nox --session minimums --force-python="3.12" -- --full-trace
set -e  # Stop on errors