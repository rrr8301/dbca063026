#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Run tests with tox
set +e  # Continue on errors
tox -e ci-py311 -- -v --color=yes