#!/bin/bash

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate

# List installed packages
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
      -DCMAKE_CUDA_FLAGS="-gencode arch=compute_75,code=sm_75" \
      .
make -k -C build -j$(nproc)

# Run C++ tests
export GTEST_OUTPUT="xml:$(realpath .)/test-results/googletest/"
make -C build test

# Run Python tests (CPU only)
pytest --junitxml=test-results/pytest/results.xml tests/test_*.py
pytest --junitxml=test-results/pytest/results-torch.xml tests/torch_*.py