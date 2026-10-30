#!/bin/bash

# Activate virtual display
Xvfb :99 -ac -screen 0 1280x1024x24 &
export DISPLAY=:99

# Install Node.js dependencies
npm ci

# Install Dash packages
python3.12 -m pip install --upgrade pip wheel
python3.12 -m pip install "setuptools<80.0.0"
find packages -name dash-*.whl -print -exec sh -c 'pip install "{}[dev,ci,testing]"' \;

# Install dash-renderer dependencies
cd dash/dash-renderer
npm ci
cd -

# Run lint
npm run lint

# Run unit tests
npm run citest.unit