#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Parse rust-toolchain to get the Rust version
# Use grep to find the line with channel = "..." and extract the version
RUST_VERSION=$(grep 'channel' rust-toolchain | grep -v '^#' | sed 's/.*channel = "\(.*\)".*/\1/')
echo "Installing Rust toolchain: $RUST_VERSION"
rustup update "$RUST_VERSION"
rustup component add clippy

# Install OCaml/opam dependencies (initialize opam if needed)
if ! opam var root > /dev/null 2>&1; then
    opam init --disable-sandboxing -y
fi
eval "$(opam env)"

# Create artifacts directory
mkdir -p $RUNNER_TEMP/artifacts

# Build buck2 binary (debug)
echo "Building buck2 binary (debug)..."
cargo build --bin=buck2 -Z unstable-options --artifact-dir=$RUNNER_TEMP/artifacts

# Run tests
echo "Running test.py..."
python3 test.py --ci --git --buck2=$RUNNER_TEMP/artifacts/buck2

echo "All tests completed successfully!"