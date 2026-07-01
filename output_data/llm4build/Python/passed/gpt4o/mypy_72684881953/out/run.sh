#!/bin/bash

# Activate Python environment
source /app/venv/bin/activate

# Install project dependencies
pip install --upgrade pip
pip install -r requirements.txt || true

# Setup tox environment
tox run -e py --notest

# Run tests
tox run -e py --skip-pkg-install -- -n 4 || true