#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source /home/testuser/.cargo/env

# Build the project
cargo build -v

# Run tests and generate documentation
cargo test -v && cargo doc -v