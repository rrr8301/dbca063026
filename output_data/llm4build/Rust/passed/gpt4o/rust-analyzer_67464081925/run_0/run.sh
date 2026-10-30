#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Rust toolchain and components
rustup update --no-self-update stable
rustup default stable
rustup component add --toolchain stable rust-src rustfmt
rustup toolchain install nightly --profile minimal --component rustfmt

# Install nextest
cargo install cargo-nextest

# Codegen checks
cargo codegen --check

# Run tests
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail

# Install cargo-machete
cargo install cargo-machete

# Run cargo-machete
cargo machete