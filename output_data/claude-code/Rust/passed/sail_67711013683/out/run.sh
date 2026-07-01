#!/usr/bin/env bash
set -e

export PATH="/root/.cargo/bin:${PATH}"

cd /app

# Run Cargo Test
echo "=== Running cargo nextest ==="
cargo nextest run --no-fail-fast || true

echo "=== Generating Rust unit coverage report ==="
if command -v grcov &> /dev/null; then
  LLVM_PATH=$(find ~/.rustup/toolchains -name "llvm-tools*" -type d | head -1)
  if [ -n "$LLVM_PATH" ]; then
    LLVM_PROFDATA="$LLVM_PATH/x86_64-unknown-linux-gnu/bin/llvm-profdata"
    if [ -f "$LLVM_PROFDATA" ]; then
      export LLVM_PATH="$(dirname $LLVM_PROFDATA)"
      grcov target/llvm-profiles/rust-unit --binary-path target/debug/ -s . \
        --llvm-path "$LLVM_PATH" \
        -t lcov --branch --ignore-not-existing \
        -o coverage-rust-unit.info || true
    fi
  fi
fi

# Run Cargo Test (Ignored) - catalog tests
echo "=== Running cargo nextest with ignored tests ==="
cargo nextest run --run-ignored ignored-only -j 6 --no-fail-fast || true

echo "=== Generating Rust slow coverage report ==="
if command -v grcov &> /dev/null; then
  LLVM_PATH=$(find ~/.rustup/toolchains -name "llvm-tools*" -type d | head -1)
  if [ -n "$LLVM_PATH" ]; then
    LLVM_PROFDATA="$LLVM_PATH/x86_64-unknown-linux-gnu/bin/llvm-profdata"
    if [ -f "$LLVM_PROFDATA" ]; then
      export LLVM_PATH="$(dirname $LLVM_PROFDATA)"
      grcov target/llvm-profiles/rust-slow --binary-path target/debug/ -s . \
        --llvm-path "$LLVM_PATH" \
        -t lcov --branch --ignore-not-existing \
        -o coverage-rust-slow.info || true
    fi
  fi
fi

echo "FINAL_STATUS = SUCCESS"
