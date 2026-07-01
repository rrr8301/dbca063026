#!/usr/bin/env bash

set -e

cd /app

echo "Running storage tests..."

cargo test -p gluesql_memory_storage --verbose
cargo test -p gluesql-shared-memory-storage --verbose
cargo test -p gluesql-composite-storage --verbose
cargo test -p gluesql-json-storage --verbose
cargo test -p gluesql-csv-storage --verbose
cargo test -p gluesql-parquet-storage --verbose
cargo test -p gluesql-file-storage --verbose
cargo test -p gluesql-redb-storage --verbose
cargo test -p gluesql_sled_storage --verbose -- --skip sled_transaction_timeout
cargo test -p gluesql_sled_storage sled_transaction_timeout --verbose -- --test-threads=1
cargo test -p gluesql_sled_storage --benches

echo "FINAL_STATUS = SUCCESS"
