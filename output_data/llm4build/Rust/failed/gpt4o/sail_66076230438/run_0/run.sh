#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Prepare coverage directories
mkdir -p target/llvm-profiles/rust-unit
mkdir -p target/llvm-profiles/rust-slow

# Run Cargo tests
cargo nextest run --no-fail-fast || true

# Generate Rust unit coverage report
LLVM_PATH=$(./.github/scripts/find-llvm-profdata.sh)
grcov target/llvm-profiles/rust-unit --binary-path target/debug/ -s . \
  --llvm-path "$LLVM_PATH" \
  -t lcov --branch --ignore-not-existing \
  -o coverage-rust-unit.info

# Run ignored Cargo tests if specified
if [ "$1" == "run_catalog_tests" ]; then
  LLVM_PROFILE_FILE=target/llvm-profiles/rust-slow/sail-%p-%m.profraw \
  cargo nextest run --run-ignored ignored-only -j 6 --no-fail-fast || true

  # Generate Rust slow coverage report
  grcov target/llvm-profiles/rust-slow --binary-path target/debug/ -s . \
    --llvm-path "$LLVM_PATH" \
    -t lcov --branch --ignore-not-existing \
    -o coverage-rust-slow.info
fi