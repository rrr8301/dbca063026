#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Set environment variables
export CI=1
export CARGO_INCREMENTAL=0
export CARGO_TERM_COLOR="always"
export DIFF=0
export RUST_LOG="off"
export SKIP_YARN_COREPACK_CHECK=1
export SWC_ECMA_TESTING_CACHE_DIR="$(pwd)/.swc-exec-cache"

# Enable corepack
corepack enable

# Install node dependencies
echo "Installing node dependencies..."
yarn

# Install global test dependencies (jest@27 and mocha)
echo "Installing global test dependencies..."
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || \
yarn global add jest@27 mocha || true

# Verify dependencies
echo "Verifying test dependencies..."
yarn jest --version && yarn mocha --version

# Create execution cache directory
mkdir -p .swc-exec-cache

# Run cargo test
echo "Running cargo test for swc..."
cargo test -p swc

# Run concurrent tests
echo "Running concurrent tests..."
./scripts/github/test-concurrent.sh swc

# Install cargo-hack
echo "Installing cargo-hack..."
cargo install cargo-hack@0.5.29

# Run cargo-hack compilation check
echo "Running cargo-hack compilation check..."
./scripts/github/run-cargo-hack.sh swc

echo "All tests completed successfully!"