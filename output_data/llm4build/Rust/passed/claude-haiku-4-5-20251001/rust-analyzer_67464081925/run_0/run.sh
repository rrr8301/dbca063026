#!/bin/bash
set -e

# Export environment variables
export CARGO_INCREMENTAL=0
export CARGO_NET_RETRY=10
export CI=1
export RUST_BACKTRACE=short
export RUSTUP_MAX_RETRIES=10
export RUSTFLAGS="-D warnings -W unreachable-pub --cfg no_salsa_async_drops"
export CC=deny_c

# Ensure Rust toolchain is up to date
rustup update --no-self-update stable
rustup default stable
rustup component add --toolchain stable rust-src rustfmt
rustup toolchain install nightly --profile minimal --component rustfmt

# Install nextest
echo "Installing nextest..."
cargo install cargo-nextest --locked

# Run codegen checks
echo "Running codegen checks..."
cargo codegen --check

# Run tests with nextest
echo "Running tests with nextest..."
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail

# Install cargo-machete
echo "Installing cargo-machete..."
cargo install cargo-machete --locked

# Run cargo-machete
echo "Running cargo-machete..."
cargo machete

echo "All checks passed!"