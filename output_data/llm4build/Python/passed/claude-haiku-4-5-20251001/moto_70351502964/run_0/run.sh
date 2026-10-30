#!/bin/bash
set -e

# Upgrade pip
python -m pip install --upgrade pip

# Install project dependencies
pip install -r requirements-dev.txt
pip install pytest-github-actions-annotate-failures

# Run tests with TESTS_SKIP_REQUIRES_DOCKER environment variable
export TESTS_SKIP_REQUIRES_DOCKER=true
pytest tests