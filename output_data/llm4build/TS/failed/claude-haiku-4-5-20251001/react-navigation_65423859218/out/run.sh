#!/bin/bash
set -e

# Run unit tests with coverage
echo "Running unit tests..."
yarn test --maxWorkers=2 --coverage

echo "Tests completed successfully!"