#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Set environment variables for tests
export CARGO_ARGS="--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env"
export WORKSPACE_EXCLUDES="--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher"
export INSTA_WORKSPACE_ROOT="/workspace"
export PYTHONPATH="/workspace/scripts"

echo "=== Running rust tests ==="
cargo test --workspace --exclude rustpython-capi $WORKSPACE_EXCLUDES --features threading $CARGO_ARGS

echo "=== Running c-api tests ==="
cd /workspace/crates/capi
cargo test
cd /workspace

echo "=== Checking compilation without host_env (sandbox mode) ==="
cargo check -p rustpython-vm --no-default-features --features compiler
cargo check -p rustpython-stdlib --no-default-features --features compiler
cargo build --no-default-features --features stdlib,importlib,stdio,encodings,freeze-stdlib

echo "=== Running sandbox smoke tests ==="
target/debug/rustpython extra_tests/snippets/sandbox_smoke.py
target/debug/rustpython extra_tests/snippets/stdlib_re.py

echo "=== Testing openssl build ==="
cargo build --no-default-features --features ssl-openssl

echo "=== Testing vendored OpenSSL build ==="
cargo build --no-default-features --features ssl-openssl-vendor

echo "=== Testing example projects ==="
cargo run --manifest-path example_projects/barebone/Cargo.toml
cargo run --manifest-path example_projects/frozen_stdlib/Cargo.toml

echo "=== Running update_lib tests ==="
cargo run -- -m unittest discover -s scripts/update_lib/tests -v

echo "=== All tests completed successfully ==="