#!/bin/bash

# Activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r flake8/docs/source/requirements.txt

# Run tests
tox -e py312