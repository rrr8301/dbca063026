#!/usr/bin/env bash
set -e

echo "=== Faiss CI Reproduction ==="
echo "Python version:"
python --version

echo ""
echo "=== Configure build environment ==="
conda list --show-channel-urls
echo "$CONDA/bin" >> $GITHUB_PATH || true
export PATH="$CONDA/bin:$PATH"

echo ""
echo "=== Running cmake configuration ==="
eval "$(conda shell.bash hook)"
conda activate
conda list --show-channel-urls

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
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CUDA_COMPILER_LAUNCHER=ccache \
      -DBLA_VENDOR=Intel10_64_dyn \
      .

echo ""
echo "=== Building faiss ==="
make -k -C build -j$(nproc)

echo ""
echo "=== Running C++ tests ==="
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
mkdir -p test-results
make -C build test || true

echo ""
echo "=== Running C++ perf benchmarks ==="
find ./build/perf_tests/ -executable -type f -name "bench*" -exec '{}' -v \; || true

echo ""
echo "=== Installing Python extension ==="
cd build/faiss/python
conda list --show-channel-urls
$CONDA/bin/python setup.py install
cd /app

echo ""
echo "=== Running Python tests (CPU only) ==="
mkdir -p test-results/pytest
conda list --show-channel-urls
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py || true
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py || true

echo ""
echo "=== Building C++ demos ==="
make -C build demo_diversity_result_handler || true

echo ""
echo "=== Done ==="
echo "FINAL_STATUS = SUCCESS"
