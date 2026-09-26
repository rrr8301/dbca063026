#!/bin/bash
set -e

# Activate Rust toolchain from rust-toolchain file
export RUSTUP_HOME="/root/.rustup"
export CARGO_HOME="/root/.cargo"
export PATH="/root/.cargo/bin:${PATH}"

# Parse rust-toolchain TOML file to get the toolchain version
# Handle both formats: [toolchain] section and direct channel = "..." syntax
RUST_TOOLCHAIN=$(grep '^channel' rust-toolchain | head -1 | cut -d'"' -f2)

if [ -z "$RUST_TOOLCHAIN" ]; then
    echo "ERROR: Could not parse Rust toolchain from rust-toolchain file"
    echo "Contents of rust-toolchain:"
    cat rust-toolchain
    exit 1
fi

echo "Installing Rust toolchain: $RUST_TOOLCHAIN"

# Install the specified Rust toolchain
rustup toolchain install "$RUST_TOOLCHAIN"
rustup default "$RUST_TOOLCHAIN"
rustup component add clippy

# Set up Haskell environment
export PATH="/root/.ghcup/bin:${PATH}"

# Verify installations
echo "=== Rust ==="
rustc --version
cargo --version

echo "=== Go ==="
go version

echo "=== Haskell ==="
ghc --version

echo "=== Python ==="
python3 --version

echo "=== Erlang ==="
erl -version

# Create artifacts directory
mkdir -p /tmp/artifacts

# Build buck2 binary (debug)
echo "=== Building buck2 binary (debug) ==="
cargo build --bin=buck2 -Z unstable-options --artifact-dir=/tmp/artifacts

# Verify buck2 binary was built
if [ ! -f /tmp/artifacts/buck2 ]; then
    echo "ERROR: buck2 binary not found at /tmp/artifacts/buck2"
    exit 1
fi

# Make buck2 executable
chmod +x /tmp/artifacts/buck2

# Run test.py
echo "=== Running test.py ==="
python3 test.py --ci --git --buck2=/tmp/artifacts/buck2

echo "=== All tests completed ==="