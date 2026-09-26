#!/bin/bash
set -e

# Initialize conda
eval "$(conda shell.bash hook)"

# Verify conda configuration
conda config --get channels

# Install Python 3.12 first with conda-forge only
conda install -y -q --override-channels -c conda-forge python=3.12

# Update conda to a stable version
conda install -y -q --override-channels -c conda-forge "conda<=25.07"

# After conda update, reconfigure to ensure conda-forge is primary and defaults are removed
conda config --remove-key channels
conda config --add channels conda-forge
conda config --set channel_priority strict
conda config --set solver libmamba
conda config --set auto_update_conda false
conda config --set show_channel_urls true

# Verify configuration
conda config --get channels

# Install core dependencies with explicit conda-forge channel only
conda install -y -q --override-channels -c conda-forge \
    cmake=3.30.4 \
    make=4.2 \
    swig=4.0 \
    "numpy>=2.0,<3.0" \
    scipy=1.16 \
    pytest=7.4 \
    gflags=2.2 \
    setuptools

# Install X86_64 specific packages
conda install -y -q --override-channels -c conda-forge \
    gxx_linux-64=14.2 \
    sysroot_linux-64=2.17

# Install OpenBLAS instead of MKL (more compatible with Python 3.12)
conda install -y -q --override-channels -c conda-forge \
    openblas=0.3.29

# Activate conda environment
conda activate

# Print conda info
conda list --show-channel-urls

# Install PyTorch CPU-only via pip (avoids channel conflicts)
# PyTorch CPU wheels support Python 3.12
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

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
      -DBLA_VENDOR=OpenBLAS \
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

# Check installed packages channel
conda list --show-channel-urls