#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming no additional dependencies are specified in the YAML

# Run tests
cargo test -- --test-threads=1