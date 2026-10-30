#!/bin/bash

set -e

# Activate Rust environment
source $HOME/.cargo/env

# Build the project
cargo build --tests --features internal

# Run tests
cargo test --features internal
cargo test --manifest-path clippy_lints/Cargo.toml
cargo test --manifest-path clippy_utils/Cargo.toml
cargo test --manifest-path rustc_tools_util/Cargo.toml
cargo test --manifest-path clippy_dev/Cargo.toml

# Run custom driver script
.github/driver.sh