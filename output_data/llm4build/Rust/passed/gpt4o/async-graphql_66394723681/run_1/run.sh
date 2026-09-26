#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Extract metadata
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')

# Build with all features
cargo build --all-features

# Build with all features except boxed-trait
cargo build --features $FEATURES

# Build the workspace
cargo build --workspace --verbose

# Run tests
cargo test --workspace --features $FEATURES

# Clean the build
cargo clean