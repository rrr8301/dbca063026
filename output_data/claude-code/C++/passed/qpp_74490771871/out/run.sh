#!/usr/bin/env bash
set -e

cd /app

# Configure Quantum++
echo "=== Configure Quantum++ ==="
cmake -B build -DQPP_ENABLE_TESTING=ON

# Install Quantum++
echo "=== Install Quantum++ ==="
cmake --install build

# Configure standalone example
echo "=== Configure standalone example ==="
cmake -S examples/standalone -B examples/standalone/build

# Build standalone example
echo "=== Build standalone example ==="
cmake --build examples/standalone/build --target standalone

# Run standalone example
echo "=== Run standalone example ==="
./examples/standalone/build/standalone

# Build examples
echo "=== Build examples ==="
cmake --build build --target examples

# Build benchmarks
echo "=== Build benchmarks ==="
cmake -S benchmarks -B benchmarks/build
cmake --build benchmarks/build

# Build unit tests
echo "=== Build unit tests ==="
cmake --build build/unit_tests --target unit_tests

# Run unit tests
echo "=== Run unit tests ==="
ctest --test-dir build -E qpp_Timer

# Uninstall Quantum++
echo "=== Uninstall Quantum++ ==="
cmake --build build --target uninstall

# Install pyqpp and test import
echo "=== Install pyqpp and test import ==="
python3 -mvenv venv
source venv/bin/activate
pip install -e .
python -c "import pyqpp; print(pyqpp.dirac(pyqpp.states.zero()))"

echo "FINAL_STATUS = SUCCESS"
