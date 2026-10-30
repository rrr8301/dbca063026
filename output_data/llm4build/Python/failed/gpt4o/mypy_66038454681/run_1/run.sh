#!/bin/bash

# Create and activate Python virtual environment
python3.11 -m venv /app/venv
source /app/venv/bin/activate

# Install project dependencies
pip install -r requirements.txt || true

# Setup tox environment
tox run -e py --notest

# Run tests
tox run -e py --skip-pkg-install -- -n 4 || true