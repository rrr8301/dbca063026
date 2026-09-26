#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
rustup update stable
rustup default stable

# Ensure cargo-nextest is installed with --locked
if ! command -v cargo-nextest &> /dev/null; then
    cargo install --locked cargo-nextest
fi

# Run tests
set -e
cargo check --workspace --bins --examples || true
cargo nextest run --workspace --no-fail-fast --exclude gix-error -- || true

# Check that tracked archives are up to date
git diff --exit-code || true