#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run tests using cargo-rbmt
cargo rbmt test --toolchain stable --lock-file recent