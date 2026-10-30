#!/bin/bash

# Activate Python environment
export UV_PYTHON_DOWNLOADS=never

# Install project dependencies
uv pip install --system .

# Run tests
nox --session "tests-3.11" -- --full-trace
nox --session minimums --force-python="3.11" -- --full-trace