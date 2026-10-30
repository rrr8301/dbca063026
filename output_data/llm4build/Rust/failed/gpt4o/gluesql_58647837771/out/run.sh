#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Navigate to the storages directory and run tests
cd storages

# Run tests for each storage
for storage in memory-storage shared-memory-storage composite-storage json-storage csv-storage parquet-storage file-storage redb-storage; do
    cd $storage
    cargo test --verbose || true
    cd ..
done

# Special handling for sled-storage
cd sled-storage
cargo test --verbose -- --skip sled_transaction_timeout || true
cargo test sled_transaction_timeout --verbose -- --test-threads=1 || true
cargo test --benches || true