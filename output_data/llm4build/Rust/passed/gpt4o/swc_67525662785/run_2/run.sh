#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Node.js dependencies
corepack enable
yarn set version stable
yarn install

# Verify dependencies
yarn jest --version && yarn mocha --version

# Configure execution cache
mkdir -p .swc-exec-cache
export SWC_ECMA_TESTING_CACHE_DIR=$(pwd)/.swc-exec-cache

# Run cargo tests
cargo test -p swc

# Run concurrent cargo tests
./scripts/github/test-concurrent.sh swc

# Check compilation
./scripts/github/run-cargo-hack.sh swc