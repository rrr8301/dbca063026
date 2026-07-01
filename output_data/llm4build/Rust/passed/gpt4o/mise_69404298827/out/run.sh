#!/bin/bash

# Activate Rust environment
source /opt/rust/cargo/env
rustup default nightly

# Build the project
cargo build --all-features

# Run tests
mise run test