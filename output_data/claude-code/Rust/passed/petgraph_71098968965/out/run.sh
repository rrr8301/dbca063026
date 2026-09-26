#!/usr/bin/env bash
set -e

# Build and test
echo "Running tests with default features..."
cargo nextest run --package petgraph --verbose

echo "Running tests with all features..."
cargo nextest run --package petgraph --all-features --verbose

echo "Tests completed successfully"
echo "FINAL_STATUS = SUCCESS"
