#!/bin/bash
set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version
cargo rbmt --version

# Run the test command with correct syntax for cargo-rbmt
# The --toolchain and --lock-file flags should be passed to cargo rbmt directly
cargo rbmt test stable recent