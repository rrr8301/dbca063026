#!/bin/bash

# Activate Python environment
python3.14 -m venv venv
source venv/bin/activate

# Install project dependencies
make

# Run tests
make ci