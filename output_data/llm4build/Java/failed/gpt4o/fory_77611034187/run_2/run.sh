#!/bin/bash

# Install project dependencies
pip install -r requirements.txt

# Run tests
python3.8 ./ci/run_ci.py java --version 17