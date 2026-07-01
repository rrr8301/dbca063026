#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Extract metadata
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')

# Build with all features
cargo build --workspace --features "$FEATURES"

# Run book tests for en language
mdbook test -L target/debug/deps ./docs/en