#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    # Install project dependencies
    pip install -r requirements.txt
else
    echo "requirements.txt not found, skipping dependency installation."
fi

# Run tests
set +e  # Continue on errors

# Check if uv is installed and use it if available
if command -v uv &> /dev/null; then
    uv run --locked tox run -e py3.11
else
    tox -e py3.11
fi