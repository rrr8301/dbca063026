#!/bin/bash
set -e

# Upgrade pip
python -m pip install --upgrade pip

# Install project dependencies
if [ -f requirements-dev.txt ]; then
    pip install -r requirements-dev.txt
fi
pip install pytest-github-actions-annotate-failures

# Run tests with TESTS_SKIP_REQUIRES_DOCKER environment variable
export TESTS_SKIP_REQUIRES_DOCKER=true
pytest tests