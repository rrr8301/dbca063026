#!/bin/bash

# Activate Python environment
source /opt/venv/bin/activate

# Run unit tests
tox -e py312 -- --exitfirst -m unit

# Run integration tests
tox -e py312 -- --exitfirst -m functional -k 'not harvesting'