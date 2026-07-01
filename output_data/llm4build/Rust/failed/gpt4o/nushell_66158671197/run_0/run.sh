#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming no additional dependencies are specified in the Cargo.toml

# Run tests
set +e  # Continue executing even if some tests fail
cargo test --workspace --profile ci --exclude nu_plugin_*

# Check for clean repository state
if [ -n "$(git status --porcelain)" ]; then
  echo "There are changes in the working directory:"
  git status --porcelain
  exit 1
else
  echo "No changes in working directory."
fi