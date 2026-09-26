#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Bazel version
echo "Bazel version:"
bazel version

# Display Rust version
echo "Rust version:"
rustc --version
cargo --version

# Display Node.js and pnpm versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version
echo "pnpm version:"
pnpm --version

# Run Bazel tests
echo "Running Bazel tests..."
bazel test //...

# Build Rust CLI in optimized mode
echo "Building Rust CLI (formatjs_cli)..."
bazel build --compilation_mode=opt //crates/formatjs_cli

# Run smoke tests on the built binary
echo "Running Rust CLI smoke tests..."
BINARY_PATH=bazel-bin/crates/formatjs_cli/formatjs_cli

if [ -f "$BINARY_PATH" ]; then
    echo "Testing: $BINARY_PATH --version"
    $BINARY_PATH --version
    
    echo "Testing: $BINARY_PATH --help"
    $BINARY_PATH --help
    
    echo "Rust CLI smoke tests passed!"
else
    echo "Error: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "All tests completed successfully!"