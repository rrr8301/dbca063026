#!/bin/bash
set -e

export BUILD_TYPE=Debug
export RUNNER_OS=Linux

# Step 1: Configure Quantum++
echo "=== Configuring Quantum++ ==="
cmake -B build -DQPP_ENABLE_TESTING=ON

# Step 2: Install Quantum++
echo "=== Installing Quantum++ ==="
cmake --install build

# Step 3: Configure standalone example
echo "=== Configuring standalone example ==="
cmake -S examples/standalone -B examples/standalone/build

# Step 4: Build standalone example
echo "=== Building standalone example ==="
cmake --build examples/standalone/build --target standalone

# Step 5: Run standalone example
echo "=== Running standalone example ==="
./examples/standalone/build/standalone

# Step 6: Build examples
echo "=== Building examples ==="
cmake --build build --target examples

# Step 7: Build benchmarks
echo "=== Building benchmarks ==="
cmake -S benchmarks -B benchmarks/build
cmake --build benchmarks/build

# Step 8: Build unit tests
echo "=== Building unit tests ==="
cmake --build build/unit_tests --target unit_tests

# Step 9: Run unit tests
echo "=== Running unit tests ==="
ctest --test-dir build -E qpp_Timer

# Step 10: Uninstall Quantum++
echo "=== Uninstalling Quantum++ ==="
cmake --build build --target uninstall

# Step 11: Install pyqpp and test import
echo "=== Installing pyqpp and testing import ==="
python3 -mvenv venv
source venv/bin/activate
pip install -e .
python -c "import pyqpp; print(pyqpp.dirac(pyqpp.states.zero()))"

echo "=== All tests completed successfully ==="