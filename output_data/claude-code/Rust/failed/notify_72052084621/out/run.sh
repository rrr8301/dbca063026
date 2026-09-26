#!/usr/bin/env bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Remove rust-toolchain.toml to allow using the configured Rust version
rm -f rust-toolchain.toml

# Display versions
rustup --version
rustc --version
cargo --version

echo "=== Building ==="
cargo build --verbose

echo "=== Building examples ==="
cargo build --examples --verbose

echo "=== Running tests ==="
cargo test --verbose || {
  echo "Tests failed, but continuing to collect output"
  TEST_FAILED=1
}

if [ -z "$TEST_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
