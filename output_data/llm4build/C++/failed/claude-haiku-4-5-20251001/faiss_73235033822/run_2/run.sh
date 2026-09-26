#!/bin/bash
set -e

# Initialize conda
eval "$(conda shell.bash hook)"

# Configure conda - ensure only conda-forge is used
conda config --remove-key channels
conda config --add channels conda-forge
conda config --set channel_priority strict
conda config --set solver libmamba
conda list --show-channel-urls

# Install conda packages - all from conda-forge
conda install -y -q -c conda-forge "conda<=25.07"
conda install -y -q -c conda-forge python=3.12 cmake=3.30.4 make=4.2 swig=4.0 "numpy>=2.0,<3.0" scipy=1.16 pytest=7.4 gflags=2.2 setuptools

# Install X86_64 specific packages
conda install -y -q -c conda-forge gxx_linux-64=14.2 sysroot_linux-64=2.17
conda install -y -q -c conda-forge mkl=2024.2.2 mkl-devel=2024.2.2

# Install PyTorch (CPU only, default)
conda install -y -q -c pytorch "pytorch<2.5"

# Activate conda environment
conda activate

# Print conda info
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
      -DBLA_VENDOR=Intel10_64_dyn \
      .

make -k -C build -j$(nproc)

# C++ tests
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

# Test avx2 loading (only if opt_level is avx2, skipped for generic)
# FAISS_DISABLE_CPU_FEATURES=AVX2 LD_DEBUG=libs $CONDA/bin/python -c "import faiss" 2>&1 | grep faiss.so
# LD_DEBUG=libs $CONDA/bin/python -c "import faiss" 2>&1 | grep faiss_avx2.so

# Check installed packages channel
conda list --show-channel-urls