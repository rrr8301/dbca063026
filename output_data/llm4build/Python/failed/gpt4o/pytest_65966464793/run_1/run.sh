#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install tox
pip install --upgrade pip
pip install tox

# Build the package from source (simulate artifact download)
python setup.py sdist

# Run tests with coverage using tox
tox -e py311-coverage --installpkg `find dist/*.tar.gz`