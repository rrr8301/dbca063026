#!/bin/bash

set -e

# Set Chromium flags for headless testing in Docker
export CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

# Install npm dependencies
npm ci

# Run the selector-native tests
npm run test:selector-native