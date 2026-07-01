#!/bin/bash

# Create and activate Python environment if it doesn't exist
if [ ! -d "/workspace/mlir_venv" ]; then
  python3.11 -m venv /workspace/mlir_venv
fi

# Activate Python environment
source /workspace/mlir_venv/bin/activate

# Install project dependencies
./build_tools/ci/install_python_deps.sh nightly

# Build the project
export CACHE_DIR="/workspace/.container-cache"
bash build_tools/ci/build_posix.sh

# Run integration tests
bash build_tools/ci/test_posix.sh nightly

# Check generated sources (only for nightly)
if [ "$TORCH_VERSION" == "nightly" ]; then
  bash build_tools/ci/check_generated_sources.sh
fi