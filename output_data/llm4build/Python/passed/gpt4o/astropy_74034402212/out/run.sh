#!/bin/bash

# Activate Python 3.12 environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r requirements.txt || true  # Assuming a requirements.txt exists

# Run tests with tox
tox -e py312-test-cov -- --cov-report=xml:${GITHUB_WORKSPACE}/coverage.xml