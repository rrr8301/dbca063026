#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming dependencies are managed by Cargo, no additional steps needed

# Run tests
cargo test --all-features