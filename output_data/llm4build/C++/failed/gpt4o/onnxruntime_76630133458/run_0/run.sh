#!/bin/bash

# Activate Python environment
export PATH=/opt/python/cp314-cp314/bin:$PATH

# Install project dependencies
pip3 install -r onnxruntime/requirements-dev.txt

# Run build and test commands
set -e

# Generate Build Files (CMake)
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# Build ONNX Runtime
cmake --build build --config Release

# Test ONNX Runtime
pytest onnxruntime/onnxruntime/python/tools/transformers/tests

# Ensure all tests are executed
set +e