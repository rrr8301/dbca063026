#!/usr/bin/env bash
set -e

cd /app

echo "=== cargo build (debug; default features) ==="
cargo build --locked

echo "=== cargo test (release; all features) ==="
cargo test --locked --release --all-features --all-targets

echo "=== cargo test --doc (release; all-features) ==="
cargo test --locked --release --all-features --doc

echo "=== cargo build (debug; no-std) ==="
cargo build --locked --lib -p rustls $(admin/all-features-except std,brotli rustls)
cargo build --locked --lib -p rustls-ring --no-default-features
cargo build --locked --lib -p rustls-aws-lc-rs --no-default-features --features aws-lc-sys

echo "=== cargo build (debug; rustls-provider-example) ==="
cargo build --locked -p rustls-provider-example

echo "=== cargo build (debug; rustls-provider-example lib in no-std mode) ==="
cargo build --locked -p rustls-provider-example --no-default-features

echo "=== cargo test (debug; rustls-provider-example; all features) ==="
cargo test --locked --all-features -p rustls-provider-example

echo "=== cargo build (debug; rustls-provider-test) ==="
cargo build --locked -p rustls-provider-test

echo "=== cargo test (debug; rustls-provider-test; all features) ==="
cargo test --locked --all-features -p rustls-provider-test

echo "=== cargo package --all-features -p rustls ==="
cargo package --all-features -p rustls

echo "FINAL_STATUS = SUCCESS"
