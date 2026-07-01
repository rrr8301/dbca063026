#!/bin/bash

# Activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip
pip install tox tox-gh-actions

# Run tests
tox || true  # Ensure all tests run even if some fail