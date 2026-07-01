#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your-username/your-repository.git /app
cd /app

# Configure the build
cmake -B build -DADA_TESTING=ON -DSHARED=ON -DSIMDUTF=ON

# Build the project
cmake --build build

# Run tests
ctest --test-dir build

# Check if run_benchmarks.sh exists and run it
if [ -f ./run_benchmarks.sh ]; then
    ./run_benchmarks.sh
else
    echo "run_benchmarks.sh not found, skipping benchmarks."
fi