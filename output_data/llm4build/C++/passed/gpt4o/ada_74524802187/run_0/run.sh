#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Configure the build
cmake -B build -DADA_TESTING=ON -DSHARED=ON -DSIMDUTF=ON

# Build the project
cmake --build build

# Run tests
ctest --test-dir build

# Run benchmarks
./run_benchmarks.sh