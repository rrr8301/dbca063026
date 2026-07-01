#!/usr/bin/env bash
set -e

cd /app

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

echo "FINAL_STATUS = SUCCESS"
