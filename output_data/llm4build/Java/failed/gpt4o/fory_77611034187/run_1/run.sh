#!/bin/bash

# Activate environments
export PATH="/opt/jdk-17/bin:$PATH"
export PATH="/usr/bin/python3.8:$PATH"

# Install project dependencies
pip install -r requirements.txt

# Run tests
python3.8 ./ci/run_ci.py java --version 17