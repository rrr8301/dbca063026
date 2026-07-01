#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --release

# Run tests
set +e  # Continue execution even if some tests fail
cargo test --all

# Test install.sh script
bash www/install.sh --to /tmp --tag 1.25.0
/tmp/just --version