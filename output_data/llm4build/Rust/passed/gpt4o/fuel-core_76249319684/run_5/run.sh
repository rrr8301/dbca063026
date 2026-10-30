#!/bin/bash

# Activate Rust environment
source "$HOME/.cargo/env"

# Run tests
cargo nextest run --all-features --workspace