#!/bin/bash

set -e

# Activate conda
eval "$(conda shell.bash hook)"
conda activate

# Print conda info
echo "=== Conda Configuration ==="
conda list --show-channel-urls
echo ""

# Create test results directory
mkdir -p test-results/googletest test-results/pytest

# Build all targets
echo "=== Building with CMake ==="
cmake -B build \
      -DBUILD_TESTING=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DFAISS_ENABLE_GPU=OFF \
      -DFAISS_ENABLE_CUVS=OFF \
      -DFAISS_ENABLE_ROCM=OFF \
      -DFAISS_OPT_LEVEL=generic \
      -DFAISS_ENABLE_SVS=OFF \
      -DFAISS_ENABLE_C_API=ON \
      -DPYTHON_EXECUTABLE=$CONDA/bin/python \
      -DCMAKE_BUILD_TYPE=Release \
      -DBLA_VENDOR=Intel10_64_dyn \
      .

echo "=== Running Make Build ==="
make -k -C build -j$(nproc)

# C++ tests
echo "=== Running C++ Tests ==="
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
make -C build test

# C++ perf benchmarks
echo "=== Running C++ Perf Benchmarks ==="
find ./build/perf_tests/ -executable -type f -name "bench*" -exec '{}' -v \;

# Install Python extension
echo "=== Installing Python Extension ==="
cd build/faiss/python
$CONDA/bin/python setup.py install
cd /workspace

# Python tests (CPU only)
echo "=== Running Python Tests (CPU) ==="
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py || true
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py || true

# Test avx2 loading (only for avx2 opt level, skip for generic)
echo "=== Skipping AVX2 test (opt_level=generic) ==="

# Print final conda info
echo ""
echo "=== Final Conda Configuration ==="
conda list --show-channel-urls

echo ""
echo "=== Build and Tests Complete ==="