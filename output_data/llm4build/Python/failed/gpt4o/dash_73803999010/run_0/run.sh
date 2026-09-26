#!/bin/bash

# Activate Python environment
source /usr/bin/activate

# Install Dash packages
find packages -name dash-*.whl -print -exec sh -c 'pip install "{}[ci,testing,dev]"' \;

# Build/Setup test components
npm run setup-tests.py

# Run typing tests
pytest tests/compliance/test_typing.py