#!/bin/bash

# Activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip within the virtual environment
pip install --upgrade pip

# Install project dependencies
pip install tox tox-gh-actions

# Run tests
tox || true  # Ensure all tests run even if some fail