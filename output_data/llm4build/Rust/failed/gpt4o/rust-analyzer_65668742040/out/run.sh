#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo fetch

# Run codegen checks (only for Ubuntu)
if [[ "$(uname -s)" == "Linux" ]]; then
    cargo codegen --check
fi

# Run tests
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail

# Run cargo-machete
cargo machete