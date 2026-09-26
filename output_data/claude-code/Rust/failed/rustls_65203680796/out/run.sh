#!/usr/bin/env bash
set -e

export RUST_BACKTRACE=1

echo "Step 1: cargo build (debug; default features)"
cargo build --locked

echo "Step 2: cargo test (release; all features)"
cargo test --locked --release --all-features --all-targets

echo "Step 3: cargo test --doc (release; all-features)"
cargo test --locked --release --all-features --doc

echo "Step 4: cargo build (debug; no-std)"
cargo build --locked --lib -p rustls $(./admin/all-features-except std,brotli rustls)
cargo build --locked --lib -p rustls-ring --no-default-features
cargo build --locked --lib -p rustls-aws-lc-rs --no-default-features --features aws-lc-sys

echo "Step 5: cargo build (debug; rustls-provider-test)"
cargo build --locked -p rustls-provider-test

echo "Step 6: cargo test (debug; rustls-provider-test; all features)"
cargo test --locked --all-features -p rustls-provider-test

echo "Step 7: cargo package --all-features -p rustls"
cargo package --all-features -p rustls

echo "FINAL_STATUS = SUCCESS"
