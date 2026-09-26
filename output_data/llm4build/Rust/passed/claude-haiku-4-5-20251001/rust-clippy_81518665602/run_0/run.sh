#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Set environment variables from the workflow
export RUST_BACKTRACE=1
export CARGO_TARGET_DIR=/workspace/target
export NO_FMT_TEST=1
export CARGO_INCREMENTAL=0
export RUSTFLAGS="-D warnings"
export OS="Linux"

echo "=== Rust Toolchain ==="
rustup show active-toolchain || rustup toolchain install
rustc --version
cargo --version

echo "=== Building with tests ==="
cargo build --tests --features internal

echo "=== Running root tests ==="
cargo test --features internal

echo "=== Testing clippy_lints ==="
cd /workspace/clippy_lints
cargo test
cd /workspace

echo "=== Testing clippy_utils ==="
cd /workspace/clippy_utils
cargo test
cd /workspace

echo "=== Testing rustc_tools_util ==="
cd /workspace/rustc_tools_util
cargo test
cd /workspace

echo "=== Testing clippy_dev ==="
cd /workspace/clippy_dev
cargo test
cd /workspace

echo "=== Testing clippy-driver ==="
bash .github/driver.sh

echo "=== All tests completed successfully ==="