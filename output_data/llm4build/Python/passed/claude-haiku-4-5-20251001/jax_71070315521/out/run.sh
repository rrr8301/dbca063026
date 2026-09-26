#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH="/usr/bin:$PATH"

# Install project dependencies
echo "Installing project dependencies..."
uv pip install --system '.[minimum-jaxlib]' -r build/test-requirements.txt

# Set test environment variables
export JAX_NUM_GENERATED_CASES=1
export JAX_ENABLE_X64=1
export JAX_ENABLE_CUSTOM_PRNG=1
export JAX_THREEFRY_PARTITIONABLE=1
export JAX_ENABLE_CHECKS=true
export JAX_SKIP_SLOW_TESTS=true
export PY_COLORS=1

# Echo environment variables for verification
echo "JAX_NUM_GENERATED_CASES=1"
echo "JAX_ENABLE_X64=1"
echo "JAX_ENABLE_CUSTOM_PRNG=1"
echo "JAX_THREEFRY_PARTITIONABLE=1"
echo "JAX_ENABLE_CHECKS=true"
echo "JAX_SKIP_SLOW_TESTS=true"

# Run tests
echo "Running tests..."
pytest -n auto --tb=short --maxfail=20 tests examples || true

echo "Test execution completed."