#!/usr/bin/env bash

set -e

cd /app

echo "Running cargo run --manifest-path demo/Cargo.toml"
cargo run --manifest-path demo/Cargo.toml

echo "Running cargo test --workspace --exclude cxx-test-suite"
cargo test --workspace --exclude cxx-test-suite

echo "Running cargo check --no-default-features --features alloc"
RUSTFLAGS="--cfg compile_error_if_std ${RUSTFLAGS}" cargo check --no-default-features --features alloc

echo "Running cargo check --no-default-features"
RUSTFLAGS="--cfg compile_error_if_alloc --cfg cxx_experimental_no_alloc ${RUSTFLAGS}" cargo check --no-default-features

echo "FINAL_STATUS = SUCCESS"
