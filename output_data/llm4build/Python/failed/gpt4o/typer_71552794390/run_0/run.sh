#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate

# Install project dependencies
uv sync --no-dev --group tests

# Create coverage directory
mkdir -p coverage

# Run test files
uv run bash scripts/test-files.sh

# Run tests
COVERAGE_FILE=coverage/.coverage.ubuntu-latest-py3.10 CONTEXT=ubuntu-latest-py3.10 uv run bash scripts/test.sh