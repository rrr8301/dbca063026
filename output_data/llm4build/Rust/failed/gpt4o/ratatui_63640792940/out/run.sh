#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Rust stable toolchain
rustup toolchain install stable
rustup default stable

# Run tests
cargo xtask test-backend crossterm