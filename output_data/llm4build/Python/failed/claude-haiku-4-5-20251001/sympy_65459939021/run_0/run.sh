#!/bin/bash
set -e

# Upgrade pip
python -m pip install --upgrade pip

# Install development requirements
pip install -r requirements-dev.txt

# Run tests with parallel execution
pytest -n auto