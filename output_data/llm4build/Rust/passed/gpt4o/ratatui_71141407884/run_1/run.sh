#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo fetch

# Run tests
cargo xtask test-backend termion