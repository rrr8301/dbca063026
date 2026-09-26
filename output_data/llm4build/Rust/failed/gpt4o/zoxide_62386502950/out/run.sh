#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --release

# Run lints and tests
set +e  # Continue on errors
just lint
just test