#!/bin/bash

# Activate Rust environment
source "$HOME/.cargo/env"

# Ensure the target directory is writable
mkdir -p /workspace/target
chmod -R 777 /workspace/target

# Run tests
cargo nextest run --all-features --workspace