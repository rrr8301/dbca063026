#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in Dockerfile, so this step is skipped

# Install stable Rust toolchain
rustup toolchain install stable
rustup default stable

# Build and test commands
set -e
cargo build --locked
cargo test --locked --release --all-features --all-targets || true
cargo test --locked --release --all-features --doc || true
cargo build --locked --lib -p rustls $(admin/all-features-except std,brotli rustls) || true
cargo build --locked --lib -p rustls-ring --no-default-features || true
cargo build --locked --lib -p rustls-aws-lc-rs --no-default-features --features aws-lc-sys || true
cargo build --locked -p rustls-provider-example || true
cargo build --locked -p rustls-provider-example --no-default-features || true
cargo test --locked --all-features -p rustls-provider-example || true
cargo build --locked -p rustls-provider-test || true
cargo test --locked --all-features -p rustls-provider-test || true
cargo package --all-features -p rustls || true