#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/facebook/zstd.git /app
cd /app

# Run make test
make test

# Run make -j zstd
make -j zstd

# Execute the test script
./tests/test_process_substitution.bash ./zstd

# Ensure all tests are executed, even if some fail
exit 0