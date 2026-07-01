#!/bin/bash

set -e

# Navigate to the workspace
cd /workspace

# Run cargo test
echo "Running cargo test..."
cargo test

echo "All tests completed successfully!"