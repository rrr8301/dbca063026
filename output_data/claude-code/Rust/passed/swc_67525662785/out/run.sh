#!/usr/bin/env bash

set -e

# Environment variables from the CI workflow
export CI=1
export CARGO_INCREMENTAL=0
export CARGO_TERM_COLOR="always"
export DIFF=0
export RUST_LOG="off"
export SKIP_YARN_COREPACK_CHECK=1

# Create cache directory for execution tests
mkdir -p .swc-exec-cache
export SWC_ECMA_TESTING_CACHE_DIR=$(pwd)/.swc-exec-cache

echo "Starting cargo test for swc crate..."
cargo test -p swc

echo ""
echo "FINAL_STATUS = SUCCESS"
