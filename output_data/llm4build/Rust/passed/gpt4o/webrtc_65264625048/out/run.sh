#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Update submodules
git submodule update --init --recursive

# Build the library
cargo build

# Run tests
cargo test --verbose