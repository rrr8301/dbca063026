#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install tox
pip install --upgrade pip
pip install tox

# Build the package from source
python setup.py sdist

# Find the built package
PACKAGE=$(find dist/*.tar.gz)

# Check if the package was created
if [ -z "$PACKAGE" ]; then
  echo "Package not found in dist/"
  exit 1
fi

# Run tests with coverage using tox
tox -e py311 --installpkg "$PACKAGE"