#!/bin/bash
set -e

# Activate conda
eval "$(conda shell.bash hook)"
conda activate

# Configure conda
conda config --set solver libmamba
conda list --show-channel-urls

# Install conda packages
conda install -y -q "conda<=25.07"
conda install -y -q python=3.12 cmake=3.30.4 make=4.2 swig=4.0 "numpy>=2.0,<3.0" scipy=1.16 pytest=7.4 gflags=2.2 setuptools

# Install X86_64 specific packages
conda install -y -q -c conda-forge gxx_linux-64=14.2 sysroot_linux-64=2.17
conda install -y -q mkl=2024.2.2 mkl-devel=2024.2.2

# Install PyTorch (CPU only)
conda install -y -q "pytorch<2.5" -c pytorch

# Show installed packages
conda list --show-channel-urls

# Build all targets
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

make -k -C build -j$(nproc)

# C++ tests
conda list --show-channel-urls
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
make -C build test

# C++ perf benchmarks
conda list --show-channel-urls
find ./build/perf_tests/ -executable -type f -name "bench*" -exec '{}' -v \;

# Install Python extension
cd build/faiss/python
conda list --show-channel-urls
$CONDA/bin/python setup.py install
cd /workspace

# Python tests (CPU only)
conda list --show-channel-urls
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py

# Test avx2 loading (skipped for generic opt_level, but included for completeness)
# FAISS_DISABLE_CPU_FEATURES=AVX2 LD_DEBUG=libs $CONDA/bin/python -c "import faiss" 2>&1 | grep faiss.so
# LD_DEBUG=libs $CONDA/bin/python -c "import faiss" 2>&1 | grep faiss_avx2.so

# Build C++ demos
make -C build demo_diversity_result_handler

# Check installed packages channel
conda list --show-channel-urls