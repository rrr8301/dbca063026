#!/bin/bash
set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version
cargo rbmt --version

# Run the test command exactly as specified in the YAML
cargo rbmt test --toolchain stable --lock-file recent