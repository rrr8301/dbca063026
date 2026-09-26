#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install project dependencies
echo "Installing project dependencies..."
python -m pip install --upgrade pip setuptools wheel
if [ -f requirements-dev.txt ]; then
    pip install -r requirements-dev.txt
fi
if [ -f pyproject.toml ]; then
    pip install -e .
fi

# Generate build files (CMake update step)
echo "Generating build files (CMake)..."
python scripts/build.py \
    --build_config Release \
    --use_binskim_compliant_compile_flags \
    --build_wheel \
    --build_nuget \
    --enable_transformers_tool_test \
    --cmake_extra_defines onnxruntime_BUILD_BENCHMARKS=ON \
    --use_cache \
    --update

# Build ONNX Runtime
echo "Building ONNX Runtime..."
python scripts/build.py \
    --build_config Release \
    --use_binskim_compliant_compile_flags \
    --build_wheel \
    --build_nuget \
    --enable_transformers_tool_test \
    --cmake_extra_defines onnxruntime_BUILD_BENCHMARKS=ON \
    --use_cache \
    --build

# Run tests
echo "Running tests..."
python scripts/build.py \
    --build_config Release \
    --use_binskim_compliant_compile_flags \
    --build_wheel \
    --build_nuget \
    --enable_transformers_tool_test \
    --cmake_extra_defines onnxruntime_BUILD_BENCHMARKS=ON \
    --use_cache \
    --test

echo "Build and test completed successfully!"