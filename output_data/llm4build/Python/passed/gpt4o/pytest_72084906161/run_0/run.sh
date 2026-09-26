#!/bin/bash

# Activate Python environment
source /usr/bin/activate

# Install project dependencies
pip install -r requirements.txt

# Run tests with coverage
tox -e py311-coverage -- --junitxml=junit.xml || true

# Ensure all tests are executed
pytest --continue-on-collection-errors || true