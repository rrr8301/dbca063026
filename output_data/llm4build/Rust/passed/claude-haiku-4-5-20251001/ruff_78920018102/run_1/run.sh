#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Install cargo-nextest
echo "Installing cargo-nextest..."
cargo install cargo-nextest --locked

# Install cargo-insta
echo "Installing cargo-insta..."
cargo install cargo-insta --locked

# Install uv
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Verify installations
echo "Verifying Rust toolchain..."
rustup show

echo "Verifying cargo-nextest..."
cargo nextest --version

echo "Verifying cargo-insta..."
cargo insta --version

echo "Verifying uv..."
uv --version

# Run tests
echo "Running insta tests with nextest..."
cargo insta test --all-features --unreferenced reject --test-runner nextest --disable-nextest-doctest

echo "Running doctests..."
cargo test --doc --all-features

echo "Dogfood ty on py-fuzzer..."
uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer

echo "Dogfood ty on the scripts directory..."
uv run --project=./scripts cargo run -p ty check --project=./scripts

echo "Dogfood ty on ty_benchmark..."
uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark

echo "Running cargo doc --all --no-deps..."
RUSTDOCFLAGS="-D warnings" cargo doc --all --no-deps

echo "Running cargo doc with private items..."
RUSTDOCFLAGS="-D warnings" cargo doc --no-deps \
  -p ty_python_semantic \
  -p ty_python_core \
  -p ty_module_resolver \
  -p ty_site_packages \
  -p ty_combine \
  -p ty_project \
  -p ty_ide \
  -p ty_wasm \
  -p ty_vendored \
  -p ty_static \
  -p ty \
  -p ty_test \
  -p ruff_db \
  -p ruff_python_formatter \
  --document-private-items

echo "All tests completed!"