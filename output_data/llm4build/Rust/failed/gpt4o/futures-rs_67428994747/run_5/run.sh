#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Rust environment
source /home/testuser/.cargo/env

# Run tests
cargo test --workspace --all-features $DOCTEST_XCOMPILE