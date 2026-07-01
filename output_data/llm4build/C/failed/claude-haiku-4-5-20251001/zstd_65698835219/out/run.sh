#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout)
if [ ! -d "zstd" ]; then
    git clone https://github.com/facebook/zstd.git
fi

cd zstd

# Run 32-bit checks
echo "Running 32-bit make check..."
CFLAGS="-m32 -O1 -fstack-protector" make check V=1

echo "Running 32-bit CLI tests..."
CFLAGS="-m32 -O1 -fstack-protector" make V=1 -C tests test-cli-tests

echo "All 32-bit tests completed successfully!"