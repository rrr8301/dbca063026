#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run tests
cargo insta test --all-features --unreferenced reject --test-runner nextest --disable-nextest-doctest
cargo test --doc --all-features

# Dogfood ty on py-fuzzer
uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer

# Dogfood ty on the scripts directory
uv run --project=./scripts cargo run -p ty check --project=./scripts

# Dogfood ty on ty_benchmark
uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark

# Generate documentation
cargo doc --all --no-deps
cargo doc --no-deps -p ty_python_semantic -p ty_python_core -p ty_module_resolver -p ty_site_packages -p ty_combine -p ty_project -p ty_ide -p ty_wasm -p ty_vendored -p ty_static -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items