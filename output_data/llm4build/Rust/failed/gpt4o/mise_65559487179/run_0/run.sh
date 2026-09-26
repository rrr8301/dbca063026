#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
mise install

# Build the project
cargo build --all-features

# Run tests
set +e  # Continue on errors
mise run test