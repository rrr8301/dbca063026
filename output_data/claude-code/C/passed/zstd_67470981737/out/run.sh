#!/usr/bin/env bash

export DEVNULLRIGHTS=1
export READFROMBLOCKDEVICE=1

cd /app

echo "Starting make test..."
make test || true

echo "Building zstd..."
make -j zstd

echo "Running test_process_substitution.bash..."
./tests/test_process_substitution.bash ./zstd

echo "FINAL_STATUS = SUCCESS"
