#!/usr/bin/env bash
set -e

cd /app

echo "Running tests..."

cd macros && cargo test --verbose && cd ..
cd core && cargo test --verbose && cd ..
cd utils && cargo test --verbose && cd ..
cd cli && cargo test --verbose && cd ..
cd pkg/rust
cargo test --lib --bins --tests --examples --verbose --no-default-features --features "gluesql_memory_storage gluesql_sled_storage"
cd ../../

echo "FINAL_STATUS = SUCCESS"
