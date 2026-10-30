#!/bin/bash

set -e

# Clone or assume repo is already present
# If running with COPY in Dockerfile, repo is already in /workspace
# Otherwise, clone it here (adjust URL as needed)
if [ ! -f "pyproject.toml" ]; then
    echo "Repository not found, cloning..."
    cd /workspace
    git clone https://github.com/geopython/pycsw.git .
fi

# Navigate to workspace
cd /workspace

# Install Python dependencies (with --break-system-packages for Ubuntu 24.04)
echo "Installing Python dependencies..."
pip3 install --break-system-packages --no-cache-dir -r requirements.txt
pip3 install --break-system-packages --no-cache-dir -r requirements-standalone.txt
pip3 install --break-system-packages --no-cache-dir -r requirements-pubsub.txt
pip3 install --break-system-packages --no-cache-dir -r requirements-dev.txt
pip3 install --break-system-packages --no-cache-dir --upgrade https://github.com/geopython/OWSLib/archive/master.zip
pip3 install --break-system-packages --no-cache-dir tox

# Set environment variable
export TOXENV=py312-sqlite
echo "TOXENV => $TOXENV"

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