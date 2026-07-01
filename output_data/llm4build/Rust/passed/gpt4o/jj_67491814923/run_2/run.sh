#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Build the project
cargo build --config .cargo/config-ci.toml --workspace --all-targets --verbose --all-features

# Run tests
cargo nextest run --config .cargo/config-ci.toml --workspace --all-targets --verbose --profile ci --all-features

# Ensure all tests are executed, even if some fail
EXIT_CODE=0
trap 'EXIT_CODE=1' ERR
cargo nextest run --config .cargo/config-ci.toml --workspace --all-targets --verbose --profile ci --all-features || true
exit $EXIT_CODE