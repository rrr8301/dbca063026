#!/bin/bash
set -e

# Ensure Rust stable is the active toolchain
rustup default stable

# Run tests
cargo test --workspace --all-features