#!/bin/bash

set -e

# Set Chromium flags for headless testing in Docker
export CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"

# Set path to chromedriver
export CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Install npm dependencies
npm ci

# Run the selector-native tests
npm run test:selector-native