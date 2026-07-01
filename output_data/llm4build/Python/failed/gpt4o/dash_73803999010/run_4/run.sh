#!/bin/bash

# Activate Python environment
python3.12 -m venv /app/venv
source /app/venv/bin/activate

# Install Dash packages if the packages directory exists
if [ -d "packages" ]; then
    find packages -name dash-*.whl -print -exec sh -c 'pip install "{}[ci,testing,dev]"' \;
else
    echo "Warning: 'packages' directory not found. Skipping Dash package installation."
fi

# Build/Setup test components
npm run setup-tests.py

# Run typing tests
pytest tests/compliance/test_typing.py