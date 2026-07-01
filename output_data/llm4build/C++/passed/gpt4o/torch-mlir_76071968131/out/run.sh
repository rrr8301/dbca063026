#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip

# Install dependencies from requirements files
pip install -r /app/pytorch-requirements.txt
pip install -r /app/test-requirements.txt

# Ensure the torch_mlir_e2e_test module is installed
pip install torch_mlir_e2e_test

# Install missing nanobind package
pip install nanobind

# Build the project
export cache_dir="${GITHUB_WORKSPACE}/.container-cache"
bash build_tools/ci/build_posix.sh

# Run integration tests
bash build_tools/ci/test_posix.sh nightly

# Check generated sources (for nightly)
if [ "$TORCH_VERSION" == "nightly" ]; then
    bash build_tools/ci/check_generated_sources.sh
fi