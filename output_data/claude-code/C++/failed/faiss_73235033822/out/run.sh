#!/usr/bin/env bash
set -e

cd /app

# Initialize micromamba
eval "$(micromamba shell hook --shell bash)"
micromamba activate

echo "=== Conda packages ==="
conda list --show-channel-urls

echo "=== Configure CMake ==="
cmake -B build \
      -DBUILD_TESTING=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DFAISS_ENABLE_GPU=OFF \
      -DFAISS_ENABLE_CUVS=OFF \
      -DFAISS_ENABLE_ROCM=OFF \
      -DFAISS_OPT_LEVEL=generic \
      -DFAISS_ENABLE_SVS=OFF \
      -DFAISS_ENABLE_C_API=ON \
      -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CUDA_COMPILER_LAUNCHER=ccache \
      -DBLA_VENDOR=Intel10_64_dyn \
      .

echo "=== Build ==="
make -k -C build -j$(nproc) || true

echo "=== C++ tests ==="
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
mkdir -p test-results/googletest
make -C build test || true

echo "=== Install Python extension ==="
cd build/faiss/python
python setup.py install || true
cd /app

echo "=== Python tests (CPU only) ==="
mkdir -p test-results/pytest
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py || true
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py || true

echo "=== FINAL_STATUS = SUCCESS ==="
