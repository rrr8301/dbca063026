#!/bin/bash
set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Update Rust to stable (as per the workflow)
rustup update stable
rustup default stable

# Install nextest with --locked flag (required by nextest)
cargo install --locked cargo-nextest

# Run tests with nextest
export GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1
cargo nextest run --workspace --no-fail-fast --exclude gix-error