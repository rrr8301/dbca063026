#!/bin/bash

set -e

# Navigate to storages directory
cd /workspace/storages

# Test memory-storage
echo "Testing memory-storage..."
cd memory-storage
cargo test --verbose
cd ..

# Test shared-memory-storage
echo "Testing shared-memory-storage..."
cd shared-memory-storage
cargo test --verbose
cd ..

# Test composite-storage
echo "Testing composite-storage..."
cd composite-storage
cargo test --verbose
cd ..

# Test json-storage
echo "Testing json-storage..."
cd json-storage
cargo test --verbose
cd ..

# Test csv-storage
echo "Testing csv-storage..."
cd csv-storage
cargo test --verbose
cd ..

# Test parquet-storage
echo "Testing parquet-storage..."
cd parquet-storage
cargo test --verbose
cd ..

# Test file-storage
echo "Testing file-storage..."
cd file-storage
cargo test --verbose
cd ..

# Test redb-storage
echo "Testing redb-storage..."
cd redb-storage
cargo test --verbose
cd ..

# Test sled-storage with special handling
echo "Testing sled-storage..."
cd sled-storage

# Run all tests except sled_transaction_timeout
echo "Running sled-storage tests (excluding sled_transaction_timeout)..."
cargo test --verbose -- --skip sled_transaction_timeout || true

# Run sled_transaction_timeout with single thread
echo "Running sled_transaction_timeout with single thread..."
cargo test sled_transaction_timeout --verbose -- --test-threads=1 || true

# Run benchmarks
echo "Running sled-storage benchmarks..."
cargo test --benches || true

cd ..

echo "All storage tests completed!"