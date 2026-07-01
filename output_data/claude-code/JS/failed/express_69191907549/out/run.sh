#!/usr/bin/env bash

set -e

# Configure npm loglevel
npm config set loglevel error

# Install dependencies
npm install

# Remove non-test dependencies
npm rm --silent --save-dev connect-redis

# Output Node and NPM versions
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

# Run tests
npm run test-ci

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
