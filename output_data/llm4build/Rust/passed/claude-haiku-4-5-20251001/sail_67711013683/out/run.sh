#!/bin/bash

set -e

# Create coverage directory
mkdir -p coverage

# Run all tests
echo "Running cargo test --all..."
cargo test --all

# Generate Rust unit coverage report
echo "Generating Rust unit coverage report..."
cargo tarpaulin --out Xml --output-dir coverage

# Run ignored tests
echo "Running cargo test --all -- --ignored..."
cargo test --all -- --ignored

# Generate Rust slow coverage report
echo "Generating Rust slow coverage report..."
cargo tarpaulin --out Xml --output-dir coverage

echo "All tests completed successfully!"