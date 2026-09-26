#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --workspace --all-features

# Run tests
cargo nextest run --workspace --all-features --profile ci
cargo test --doc --all-features
RUSTFLAGS="--cfg dst --cfg tokio_unstable" cargo nextest run -p slatedb-dst --all-features --profile dst