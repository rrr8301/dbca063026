#!/bin/bash
set -e

# Create .cargo directory and configure mold linker
mkdir -p .cargo
cat >> .cargo/config.toml <<EOF
[target.x86_64-unknown-linux-gnu]
linker = "gcc"
rustflags = ["-C", "link-arg=-fuse-ld=mold"]
EOF

# Build the workspace with tests
cargo build --workspace --tests --locked

# Run tests using nextest
cargo nextest run --workspace --profile ci --locked