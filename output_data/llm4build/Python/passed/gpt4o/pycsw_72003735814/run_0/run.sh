#!/bin/bash

# Activate Python environment
source /usr/bin/python3.12

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app

# Navigate to the app directory
cd /app

# Run unit tests
tox -e py312 -- --exitfirst -m unit

# Run integration tests
tox -e py312 -- --exitfirst -m functional -k 'not harvesting'

# Build documentation
cd docs && make html