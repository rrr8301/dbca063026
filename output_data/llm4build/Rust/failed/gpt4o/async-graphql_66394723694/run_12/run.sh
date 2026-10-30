#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source $HOME/.cargo/env

# Extract metadata
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')

# Check if FEATURES is empty and handle it
if [ -z "$FEATURES" ]; then
  echo "No features found for async-graphql. Exiting."
  exit 1
fi

# Build with all features
cargo build --workspace --features "$FEATURES"

# Run book tests for en language
mdbook test -L target/debug/deps ./docs/en