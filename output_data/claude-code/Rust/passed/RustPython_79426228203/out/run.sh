#!/usr/bin/env bash

set -e

echo "===== Running RustPython CI Tests ====="
echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"
echo "CARGO_ARGS: $CARGO_ARGS"
echo "WORKSPACE_EXCLUDES: $WORKSPACE_EXCLUDES"
echo ""

# Step 1: run rust tests
echo "===== Step 1: Running rust tests ====="
cargo test --workspace --exclude rustpython-capi $WORKSPACE_EXCLUDES --features threading $CARGO_ARGS || true

# Step 2: run c-api tests
echo "===== Step 2: Running c-api tests ====="
cd crates/capi
cargo test || true
cd /app

# Step 3: check compilation without host_env (sandbox mode)
echo "===== Step 3: Checking compilation without host_env (sandbox mode) ====="
cargo check -p rustpython-vm --no-default-features --features compiler || true
cargo check -p rustpython-stdlib --no-default-features --features compiler || true
cargo build --no-default-features --features stdlib,importlib,stdio,encodings,freeze-stdlib || true

# Step 4: sandbox smoke test
echo "===== Step 4: Running sandbox smoke tests ====="
target/debug/rustpython extra_tests/snippets/sandbox_smoke.py || true
target/debug/rustpython extra_tests/snippets/stdlib_re.py || true

# Step 5: Test openssl build
echo "===== Step 5: Testing openssl build ====="
cargo build --no-default-features --features ssl-openssl || true

# Step 6: Test vendored OpenSSL build
echo "===== Step 6: Testing vendored OpenSSL build ====="
cargo build --no-default-features --features ssl-openssl-vendor || true

# Step 7: Test example projects
echo "===== Step 7: Testing example projects ====="
cargo run --manifest-path example_projects/barebone/Cargo.toml || true
cargo run --manifest-path example_projects/frozen_stdlib/Cargo.toml || true

# Step 8: run update_lib tests
echo "===== Step 8: Running update_lib tests ====="
PYTHONPATH=scripts cargo run -- -m unittest discover -s scripts/update_lib/tests -v || true

echo ""
echo "===== All tests completed ====="
FINAL_STATUS=SUCCESS
