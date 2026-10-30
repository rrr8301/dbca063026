#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run tests
cargo test --workspace --profile ci --exclude nu_plugin_*