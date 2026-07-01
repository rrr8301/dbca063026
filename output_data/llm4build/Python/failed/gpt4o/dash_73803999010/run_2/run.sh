#!/bin/bash

# Activate Python environment
python3.12 -m venv /app/venv
source /app/venv/bin/activate

# Install Dash packages
find packages -name dash-*.whl -print -exec sh -c 'pip install "{}[ci,testing,dev]"' \;

# Build/Setup test components
npm run setup-tests.py

# Run typing tests
pytest tests/compliance/test_typing.py