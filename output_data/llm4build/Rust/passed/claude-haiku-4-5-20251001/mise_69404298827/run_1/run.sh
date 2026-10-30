#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"
export PATH="/root/.local/bin:${PATH}"

# Install mise tools (replicate .github/actions/mise-tools)
echo "Installing mise tools..."
mise install

# Build the project with all features
echo "Building project with all features..."
cargo build --all-features

# Add debug target to PATH
export PATH="$PWD/target/debug:${PATH}"

# Run tests using mise
echo "Running tests..."
mise run test

echo "All tests completed successfully!"