#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/rustls/rustls.git /app
cd /app

# Install stable Rust toolchain
rustup toolchain install stable
rustup default stable

# Run cargo build and test commands
cargo build --locked
cargo test --locked --release --all-features --all-targets
cargo test --locked --release --all-features --doc
cargo build --locked --lib -p rustls $(admin/all-features-except std,brotli rustls)
cargo build --locked --lib -p rustls-ring --no-default-features
cargo build --locked --lib -p rustls-aws-lc-rs --no-default-features --features aws-lc-sys
cargo build --locked -p rustls-provider-example
cargo build --locked -p rustls-provider-example --no-default-features
cargo test --locked --all-features -p rustls-provider-example
cargo build --locked -p rustls-provider-test
cargo test --locked --all-features -p rustls-provider-test
cargo package --all-features -p rustls