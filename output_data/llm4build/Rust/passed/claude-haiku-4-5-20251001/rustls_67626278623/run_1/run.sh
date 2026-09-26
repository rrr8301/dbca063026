#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Navigate to workspace
cd /workspace

# cargo build (debug; default features)
echo "=== cargo build (debug; default features) ==="
cargo build --locked

# cargo test (release; all features)
echo "=== cargo test (release; all features) ==="
RUST_BACKTRACE=1 cargo test --locked --release --all-features --all-targets

# cargo test --doc (release; all-features)
echo "=== cargo test --doc (release; all-features) ==="
RUST_BACKTRACE=1 cargo test --locked --release --all-features --doc

# cargo build (debug; no-std)
echo "=== cargo build (debug; no-std) ==="
cargo build --locked --lib -p rustls $(admin/all-features-except std,brotli rustls)
cargo build --locked --lib -p rustls-ring --no-default-features
cargo build --locked --lib -p rustls-aws-lc-rs --no-default-features --features aws-lc-sys

# cargo build (debug; rustls-provider-example)
echo "=== cargo build (debug; rustls-provider-example) ==="
cargo build --locked -p rustls-provider-example

# cargo build (debug; rustls-provider-example lib in no-std mode)
echo "=== cargo build (debug; rustls-provider-example lib in no-std mode) ==="
cargo build --locked -p rustls-provider-example --no-default-features

# cargo test (debug; rustls-provider-example; all features)
echo "=== cargo test (debug; rustls-provider-example; all features) ==="
cargo test --locked --all-features -p rustls-provider-example

# cargo build (debug; rustls-provider-test)
echo "=== cargo build (debug; rustls-provider-test) ==="
cargo build --locked -p rustls-provider-test

# cargo test (debug; rustls-provider-test; all features)
echo "=== cargo test (debug; rustls-provider-test; all features) ==="
cargo test --locked --all-features -p rustls-provider-test

# cargo package --all-features -p rustls
echo "=== cargo package --all-features -p rustls ==="
cargo package --all-features -p rustls

echo "=== All tests completed successfully ==="