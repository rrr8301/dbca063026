#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source $HOME/.cargo/env

# Install Rust toolchain and components
rustup update --no-self-update stable
rustup default stable
rustup component add --toolchain stable rust-src rustfmt
rustup toolchain install nightly --profile minimal --component rustfmt

# Install nextest with --locked
cargo install --locked cargo-nextest

# Codegen checks
cargo codegen --check || { echo "Codegen check failed"; exit 1; }

# Run tests
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail || { echo "Tests failed"; exit 1; }

# Install cargo-machete
cargo install cargo-machete

# Run cargo-machete
cargo machete || { echo "Cargo machete failed"; exit 1; }

echo "Script executed successfully."