#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run rust tests
cargo test --workspace --exclude rustpython-capi $WORKSPACE_EXCLUDES --features threading $CARGO_ARGS

# Run c-api tests
cd crates/capi
cargo test

# Check compilation without host_env (sandbox mode)
cd /workspace
cargo check -p rustpython-vm --no-default-features --features compiler
cargo check -p rustpython-stdlib --no-default-features --features compiler
cargo build --no-default-features --features stdlib,importlib,stdio,encodings,freeze-stdlib

# Sandbox smoke test
target/debug/rustpython extra_tests/snippets/sandbox_smoke.py
target/debug/rustpython extra_tests/snippets/stdlib_re.py

# Test openssl build
cargo build --no-default-features --features ssl-openssl

# Test vendored OpenSSL build
cargo build --no-default-features --features ssl-openssl-vendor

# Test example projects
cargo run --manifest-path example_projects/barebone/Cargo.toml
cargo run --manifest-path example_projects/frozen_stdlib/Cargo.toml

# Run update_lib tests
cargo run -- -m unittest discover -s scripts/update_lib/tests -v