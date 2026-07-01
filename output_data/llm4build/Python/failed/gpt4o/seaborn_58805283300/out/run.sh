#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
EXTRAS=',stats'
DEPS='-r ci/deps_pinned.txt'
pip install .[dev$EXTRAS] $DEPS

# Run tests
make test