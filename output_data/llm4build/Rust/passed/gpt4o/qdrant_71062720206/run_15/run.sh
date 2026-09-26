#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install nextest
cargo install cargo-nextest

# Enable mold linker
mkdir -p .cargo
echo "[target.x86_64-unknown-linux-gnu]" >> .cargo/config.toml
echo "linker = \"clang\"" >> .cargo/config.toml
echo "rustflags = [\"-C\", \"link-arg=-fuse-ld=/usr/local/bin/mold\"]" >> .cargo/config.toml

# Build the project
cargo build --workspace --tests --locked

# Run tests
cargo nextest run --workspace --profile ci --locked