#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm use)
# Not needed here as we're using a specific Node.js version in Docker

# Install project dependencies
yarn install --immutable

# Build the project
yarn build:js

# Get number of CPU cores
CPU_CORES=$(nproc)

# Run node-env tests
yarn workspace jest-environment-node test

# Run tests with retries
for i in {1..3}; do
  yarn test-ci-partial:parallel --max-workers $CPU_CORES --shard=3/3 && break
  echo "Retrying tests... ($i)"
done

# Run tests using jest-jasmine
for i in {1..3}; do
  yarn jest-jasmine-ci --max-workers $CPU_CORES --shard=3/3 && break
  echo "Retrying jest-jasmine tests... ($i)"
done