#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install project dependencies
npm install

# Run the utoo setup (simulated)
echo "Setting up utoo..."
# Placeholder for actual setup command
# e.g., npm install -g utoo

# Run tests
echo "Running tests..."
ut
ut test -- --maxWorkers=2 --shard=1/2 --coverage

# Ensure all tests run even if some fail
set +e
ut test -- --maxWorkers=2 --shard=1/2 --coverage
set -e