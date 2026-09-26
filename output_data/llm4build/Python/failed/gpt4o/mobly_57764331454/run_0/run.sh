#!/bin/bash

# Activate Python environment
source /usr/bin/activate

# Install project dependencies
pip install -r mobly/docs/requirements.txt

# Run tests using tox
tox -e py311

# Check formatting
pyink --check .