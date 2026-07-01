#!/bin/bash

set -e

# Verify Rust installation
echo "=== Verifying Rust installation ==="
rustup show
cargo --version
rustc --version

# Verify Python installation
echo "=== Verifying Python installation ==="
python3 --version

# Compile tests for all specified crates
echo "=== Compiling tests ==="
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

# Run tests for all specified crates
# Note: Running tests unconditionally (the GitHub Actions job skips on main branch,
# but for local Docker builds we run all tests)
echo "=== Running tests ==="
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
  -p polars-utils

echo "=== All tests completed successfully ==="