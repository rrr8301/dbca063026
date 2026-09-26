#!/bin/bash

# Create and activate Python virtual environment
python3 -m venv /app/venv
source /app/venv/bin/activate

# Upgrade pip in the virtual environment
pip install --upgrade pip

# Install project dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt not found, skipping dependency installation."
fi

# Run tests with coverage
tox -e py311-coverage -- --junitxml=junit.xml || true

# Ensure all tests are executed
pytest --continue-on-collection-errors || true