#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Navigate to the app directory
cd /app

# Install project dependencies
python3 -m pip install --upgrade setuptools pip tox virtualenv

# Run tests using tox
tox -e py310