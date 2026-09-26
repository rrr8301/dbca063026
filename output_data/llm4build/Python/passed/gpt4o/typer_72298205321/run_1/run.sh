#!/bin/bash

# Activate the virtual environment
source /opt/venv/bin/activate

# Install project dependencies
uv sync --no-dev --group tests

# Create coverage directory
mkdir -p coverage

# Run test files script
uv run bash scripts/test-files.sh

# Run tests
COVERAGE_FILE=coverage/.coverage.ubuntu-latest-py3 CONTEXT=ubuntu-latest-py3 uv run bash scripts/test.sh