#!/bin/bash

# Activate the environment (if needed, Node.js doesn't require activation)

# Install project dependencies (already done in Dockerfile, but ensure it's up-to-date)
corepack yarn install --immutable

# Build the project (already done in Dockerfile, but ensure it's up-to-date)
corepack yarn build

# Run tests and ensure all tests are executed
set +e  # Continue on errors
corepack yarn test
set -e  # Stop on errors