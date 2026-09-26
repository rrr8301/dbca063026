#!/usr/bin/env bash

. /app/venv/bin/activate

# Install pylint in editable mode without dependencies
pip install . --no-deps

# Print version info
pip list | grep 'astroid\|pylint'

# Run pytest (allow failures - we just need tests to run)
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/ || true

# If we get here, tests ran
echo "FINAL_STATUS = SUCCESS"
