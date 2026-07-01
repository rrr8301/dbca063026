#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install project dependencies
pnpm install --shamefully-hoist

# Check if a test script is defined in package.json
if ! pnpm run | grep -q "test"; then
  echo "No test script found in package.json. Please define a test script."
  exit 1
fi

# Run tests
pnpm run test || echo "Tests failed. Please check the test script in package.json."