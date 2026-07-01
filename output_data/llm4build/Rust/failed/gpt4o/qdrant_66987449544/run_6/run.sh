#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Configure mold
mkdir -p .cargo
echo "[target.x86_64-unknown-linux-gnu]" > .cargo/config.toml
echo "linker = \"clang\"" >> .cargo/config.toml
echo "rustflags = [\"-C\", \"link-arg=-fuse-ld=/usr/local/bin/mold\"]" >> .cargo/config.toml

# Compile protobuf files with the necessary flag
PROTO_DIR="src/grpc/proto"
for proto_file in $PROTO_DIR/*.proto; do
    protoc --proto_path=$PROTO_DIR --rust_out=src/grpc --experimental_allow_proto3_optional $proto_file
done

# Build the project
cargo build --workspace --features rocksdb --tests --locked

# Run tests
cargo nextest run --workspace --features rocksdb --profile ci --locked