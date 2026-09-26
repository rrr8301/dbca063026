#!/bin/bash
set -e

# Ensure Rust toolchain is available
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Run the test command
cargo xtask test-backend termion