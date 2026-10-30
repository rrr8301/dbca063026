#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo fetch

# Run tests
set -e
cargo test -p ty_python_semantic --test mdtest || true
cargo insta test --all-features --unreferenced reject --test-runner nextest || true
uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer || true
uv run --project=./scripts cargo run -p ty check --project=./scripts || true
uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark || true
cargo doc --all --no-deps || true
cargo doc --no-deps -p ty_python_semantic -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items || true