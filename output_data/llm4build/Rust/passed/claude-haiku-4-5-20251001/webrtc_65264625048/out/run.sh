#!/bin/bash

set -e

# Initialize git submodules
echo "Initializing git submodules..."
git submodule update --init --recursive

# Run cargo tests with verbose output
echo "Running cargo tests..."
cargo test --verbose

echo "All tests completed successfully!"