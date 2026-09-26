#!/bin/bash

# Activate Rust environment
source /home/testuser/.cargo/env

# Build the project
cargo build -v

# Run tests and generate documentation
cargo test -v && cargo doc -v