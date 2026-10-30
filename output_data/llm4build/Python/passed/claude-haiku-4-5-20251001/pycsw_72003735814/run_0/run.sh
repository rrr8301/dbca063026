#!/bin/bash
set -e

# Install Python build tools
pip install setuptools

# Install project requirements
pip install -r requirements.txt
pip install -r requirements-standalone.txt
pip install -r requirements-pubsub.txt
pip install -r requirements-dev.txt

# Install OWSLib from master branch
pip install --upgrade https://github.com/geopython/OWSLib/archive/master.zip

# Install tox
pip install tox

echo "TOXENV => py312-sqlite"

# Run unit tests
echo "Running unit tests..."
tox -- --exitfirst -m unit

# Run integration tests
echo "Running integration tests..."
tox -- --exitfirst -m functional -k 'not harvesting'

# Build documentation
echo "Building documentation..."
cd docs && make html

echo "All tests and builds completed successfully!"