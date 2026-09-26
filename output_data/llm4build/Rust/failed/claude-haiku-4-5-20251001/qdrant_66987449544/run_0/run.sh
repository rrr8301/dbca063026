#!/bin/bash
set -e

# Enable mold on Linux
mkdir -p .cargo
echo "[target.x86_64-unknown-linux-gnu]" >> .cargo/config.toml
echo "linker = \"clang\"" >> .cargo/config.toml
echo "rustflags = [\"-C\", \"link-arg=-fuse-ld=/usr/local/bin/mold\"]" >> .cargo/config.toml

# Build
cargo build --workspace --features rocksdb --tests --locked

# Run tests
cargo nextest run --workspace --features rocksdb --profile ci --locked