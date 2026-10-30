#!/bin/bash
set -e

# Create and activate virtual environment
python3.14 -m venv venv
. venv/bin/activate

# Upgrade pip, setuptools, wheel
pip install --upgrade pip setuptools wheel

# Install test dependencies
if [ -f requirements_test.txt ]; then
    pip install -r requirements_test.txt
fi

if [ -f requirements_test_min.txt ]; then
    pip install -r requirements_test_min.txt
fi

if [ -f requirements_test_pre_commit.txt ]; then
    pip install -r requirements_test_pre_commit.txt
fi

# Install the package in editable mode without dependencies
pip install . --no-deps

# Display installed versions
pip list | grep -E 'astroid|pylint' || true

# Run pytest with exact flags from YAML
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/