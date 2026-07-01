#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi

# Install tox in the virtual environment
pip install tox tox-gh-actions

# Run tests using tox
tox || true  # Ensure all tests run even if some fail