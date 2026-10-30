#!/bin/bash

set -e

# Activate Rust environment
source $HOME/.cargo/env

# Build the project
cargo build --tests --features internal

# Run tests
cargo test --features internal