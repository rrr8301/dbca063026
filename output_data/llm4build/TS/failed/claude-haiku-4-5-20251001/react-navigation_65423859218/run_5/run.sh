#!/bin/bash
set -e

# Install dependencies
echo "Installing dependencies..."
yarn install --immutable

# Run unit tests with coverage
echo "Running unit tests..."
yarn test --maxWorkers=2 --coverage

echo "Tests completed successfully!"