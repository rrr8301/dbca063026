#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Compile tests
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

# Run tests
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
    -p polars-utils || true  # Ensure all tests run even if some fail