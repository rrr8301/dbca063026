#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r requirements-dev.txt
pip install pytest-github-actions-annotate-failures

# Run tests with pytest
TESTS_SKIP_REQUIRES_DOCKER=true pytest tests