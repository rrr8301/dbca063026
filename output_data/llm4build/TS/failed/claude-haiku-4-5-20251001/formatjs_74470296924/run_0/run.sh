#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run Bazel tests
echo "Running Bazel tests..."
bazel test //...

# Build Rust CLI in optimized mode
echo "Building Rust CLI (formatjs_cli)..."
bazel build --compilation_mode=opt //crates/formatjs_cli

# Run smoke tests on the built binary
echo "Running Rust CLI smoke tests..."
BINARY_PATH=bazel-bin/crates/formatjs_cli/formatjs_cli

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "Testing: $BINARY_PATH --version"
$BINARY_PATH --version

echo "Testing: $BINARY_PATH --help"
$BINARY_PATH --help

echo "All tests completed successfully!"