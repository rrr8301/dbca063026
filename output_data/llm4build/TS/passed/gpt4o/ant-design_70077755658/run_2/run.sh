#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install project dependencies
npm install --legacy-peer-deps || true

# Run the utoo setup (simulated)
echo "Setting up utoo..."
# Placeholder for actual setup command
# e.g., npm install -g utoo

# Run tests
echo "Running tests..."
set +e
ut
ut test -- --maxWorkers=2 --shard=1/2 --coverage
set -e