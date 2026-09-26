#!/usr/bin/env bash
set -e

echo "=== Configure standalone example ==="
cmake -S examples/standalone -B examples/standalone/build

echo "=== Build standalone example ==="
cmake --build examples/standalone/build --target standalone

echo "=== Run standalone example ==="
./examples/standalone/build/standalone

echo "=== Build examples ==="
cmake --build build --target examples

echo "=== Build benchmarks ==="
cmake -S benchmarks -B benchmarks/build
cmake --build benchmarks/build

echo "=== Build unit tests ==="
cmake --build build/unit_tests --target unit_tests

echo "=== Run unit tests ==="
ctest --test-dir build -E qpp_Timer

echo "=== Install pyqpp and test import ==="
python3 -m venv venv
source venv/bin/activate
pip install -e .

echo "=== Test pyqpp import ==="
python -c "import pyqpp; print(pyqpp.dirac(pyqpp.states.zero()))"

echo "FINAL_STATUS = SUCCESS"
