#!/bin/bash

set -e

# Clone the repository
git clone https://github.com/softwareQinc/qpp.git /workspace/repo
cd /workspace/repo

# Configure Quantum++
cmake -B build -DQPP_ENABLE_TESTING=ON

# Install Quantum++
cmake --install build

# Configure standalone example
cmake -S examples/standalone -B examples/standalone/build

# Build standalone example
cmake --build examples/standalone/build --target standalone

# Run standalone example
./examples/standalone/build/standalone

# Build examples
cmake --build build --target examples

# Build benchmarks
cmake -S benchmarks -B benchmarks/build
cmake --build benchmarks/build

# Build unit tests
cmake --build build/unit_tests --target unit_tests

# Run unit tests (continue even if some fail)
ctest --test-dir build -E qpp_Timer || true

echo "Build and test workflow completed."