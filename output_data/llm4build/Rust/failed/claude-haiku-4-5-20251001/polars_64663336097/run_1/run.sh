#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_failed=0

echo "=== Rust Environment ==="
rustup show
cargo --version
rustc --version

echo ""
echo "=== Python Environment ==="
python3 --version

echo ""
echo "=== Compiling Tests ==="
cargo test --lib --tests --bins --all-features --no-run \
  -p polars-arrow \
  -p polars-compute \
  -p polars-core \
  -p polars-io \
  -p polars-lazy \
  -p polars-ops \
  -p polars-parquet \
  -p polars-plan \
  -p polars-row \
  -p polars-sql \
  -p polars-time \
  -p polars-utils

echo ""
echo "=== Running Tests ==="
cargo test --lib --tests --bins --all-features \
  -p polars-arrow \
  -p polars-compute \
  -p polars-core \
  -p polars-io \
  -p polars-lazy \
  -p polars-ops \
  -p polars-parquet \
  -p polars-plan \
  -p polars-row \
  -p polars-sql \
  -p polars-time \
  -p polars-utils || test_failed=1

echo ""
if [ $test_failed -eq 0 ]; then
  echo "=== All Tests Passed ==="
  exit 0
else
  echo "=== Some Tests Failed ==="
  exit 1
fi