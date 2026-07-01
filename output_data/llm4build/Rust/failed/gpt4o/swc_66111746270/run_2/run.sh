#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Enable corepack
corepack enable

# Install Node.js dependencies
yarn install

# Verify Node.js dependencies
yarn jest --version && yarn mocha --version

# Run cargo tests based on matrix settings
# Placeholder for matrix settings logic
# Assuming a default crate for demonstration
DEFAULT_CRATE="swc_ecma_parser"

# Run cargo tests
cargo test -p $DEFAULT_CRATE --all-features || true

# Additional cargo test commands based on matrix settings can be added here