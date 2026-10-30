#!/bin/bash

# Create and activate Python environment if it doesn't exist
if [ ! -d "/workspace/mlir_venv" ]; then
  python3.11 -m venv /workspace/mlir_venv
fi

# Activate Python environment
source /workspace/mlir_venv/bin/activate

# Upgrade pip in the virtual environment
pip install --upgrade pip

# Install project dependencies
if [ -f "./build_tools/ci/install_python_deps.sh" ]; then
  chmod +x ./build_tools/ci/install_python_deps.sh
  ./build_tools/ci/install_python_deps.sh nightly
else
  echo "Warning: install_python_deps.sh not found, skipping dependency installation."
fi

# Ensure necessary directories exist
mkdir -p /workspace/externals/llvm-project/mlir/python
mkdir -p /workspace/externals/llvm-project/llvm

# Build the project
export CACHE_DIR="/workspace/.container-cache"
if [ -f "build_tools/ci/build_posix.sh" ]; then
  chmod +x build_tools/ci/build_posix.sh
  bash build_tools/ci/build_posix.sh
else
  echo "Warning: build_posix.sh not found, skipping build."
fi

# Run integration tests
if [ -f "build_tools/ci/test_posix.sh" ]; then
  chmod +x build_tools/ci/test_posix.sh
  bash build_tools/ci/test_posix.sh nightly
else
  echo "Warning: test_posix.sh not found, skipping tests."
fi

# Check generated sources (only for nightly)
if [ "$TORCH_VERSION" == "nightly" ]; then
  if [ -f "build_tools/ci/check_generated_sources.sh" ]; then
    chmod +x build_tools/ci/check_generated_sources.sh
    bash build_tools/ci/check_generated_sources.sh
  else
    echo "Warning: check_generated_sources.sh not found, skipping source check."
  fi
fi