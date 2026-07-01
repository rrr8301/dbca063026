#!/bin/bash

# Activate Python environment
python3.10 -m venv venv
source venv/bin/activate

# Install project dependencies and CRT
python scripts/ci/install --extras crt

# Run tests
python scripts/ci/run-crt-tests --with-cov --with-xdist