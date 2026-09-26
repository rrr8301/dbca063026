#!/bin/bash

# Source the Rust environment
source $HOME/.cargo/env

# Set environment variables
export CARGO_TERM_COLOR=always
export RUST_BACKTRACE=full
export CI=true
export CARGO_PROFILE_DEV_DEBUG=false
export CARGO_PROFILE_TEST_DEBUG=false
export CARGO_PROFILE_DEV_OPT_LEVEL=1
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
export CARGO_TARGET_DIR=target
export ROCKSDB_DISABLE_JEMALLOC=1

# Set the PROTOC environment variable to the path of the protoc binary
export PROTOC=$(which protoc)

# Add the protobuf include path to the environment
PROTOBUF_INCLUDE_PATH=$(dirname $(find /usr -name "google" -type d | head -n 1))
export PROTOC_INCLUDE_PATHS="$PROTOBUF_INCLUDE_PATH"

# Add the experimental flag for proto3 optional fields
export PROTOC_FLAGS="--experimental_allow_proto3_optional"

# Build the project
cargo build --workspace --all-features

# Run tests
cargo test --workspace --all-features