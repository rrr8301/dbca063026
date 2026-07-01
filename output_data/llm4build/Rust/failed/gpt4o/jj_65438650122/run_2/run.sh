#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Build the project
cargo build --config .cargo/config-ci.toml --workspace --all-targets --verbose --all-features

# Run tests
set +e  # Continue on errors
cargo nextest run --config .cargo/config-ci.toml --workspace --all-targets --verbose --profile ci --all-features