#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build

# Run tests
set +e  # Continue on errors
just ci-test