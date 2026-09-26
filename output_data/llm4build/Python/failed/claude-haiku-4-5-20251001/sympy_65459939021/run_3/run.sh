#!/bin/bash
set -e

# Upgrade pip with --break-system-packages to handle Debian-managed pip
python3 -m pip install --upgrade pip --break-system-packages

# Install development requirements
pip install -r requirements-dev.txt

# Run tests with parallel execution
pytest -n auto