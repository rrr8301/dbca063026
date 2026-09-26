#!/bin/bash

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate

# Install additional dependencies based on architecture and GPU/ROCm support
if [ "$(uname -m)" = "x86_64" ]; then
    conda install -y -c conda-forge gxx_linux-64=14.2 sysroot_linux-64=2.17 mkl=2024.2.2 mkl-devel=2024.2.2
fi

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
      -DPYTHON_EXECUTABLE=$(which python) \
      -DCMAKE_BUILD_TYPE=Release \
      .
make -k -C build -j$(nproc)

# Run C++ tests
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
make -C build test

# Install Python extension
cd build/faiss/python
python setup.py install
cd -

# Run Python tests (CPU only)
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py