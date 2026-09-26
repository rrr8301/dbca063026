#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set the registry to the default npm registry
pnpm config set registry https://registry.npmjs.org/

# Install project dependencies without the --no-optional flag
pnpm install --shamefully-hoist || { echo "Failed to install dependencies. Please check the package.json and pnpm-lock.yaml."; exit 1; }

# Check if a test script is defined in package.json
if ! pnpm run | grep -q "test"; then
  echo "No test script found in package.json. Please define a test script."
  exit 1
fi

# Run tests
pnpm run test || { echo "Tests failed. Please check the test script in package.json."; exit 1; }