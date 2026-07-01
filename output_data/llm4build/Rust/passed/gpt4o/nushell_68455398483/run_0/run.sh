#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Set environment variables
export NUSHELL_CARGO_PROFILE=ci
export NU_LOG_LEVEL=DEBUG

# Run tests
cargo +beta test --workspace --profile ci --exclude nu_plugin_*

# Check for clean repository
if [ -n "$(git status --porcelain)" ]; then
  echo "there are changes"
  git status --porcelain
  exit 1
else
  echo "no changes in working directory"
fi