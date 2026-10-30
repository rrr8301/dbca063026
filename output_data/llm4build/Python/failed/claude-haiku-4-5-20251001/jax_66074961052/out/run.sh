#!/bin/bash
set -e

# Set test environment variables
export JAX_NUM_GENERATED_CASES=1
export JAX_ENABLE_X64=0
export JAX_ENABLE_CUSTOM_PRNG=0
export JAX_THREEFRY_PARTITIONABLE=0
export JAX_ENABLE_CHECKS=true
export JAX_SKIP_SLOW_TESTS=true
export PY_COLORS=1

# Print environment for debugging
echo "JAX_NUM_GENERATED_CASES=1"
echo "JAX_ENABLE_X64=0"
echo "JAX_ENABLE_CUSTOM_PRNG=0"
echo "JAX_THREEFRY_PARTITIONABLE=0"
echo "JAX_ENABLE_CHECKS=true"
echo "JAX_SKIP_SLOW_TESTS=true"

# Run tests with pytest
# Using -n auto for parallel execution (requires pytest-xdist)
# --maxfail=20 allows up to 20 failures before stopping
# --tb=short provides concise traceback format
pytest -n auto --tb=short --maxfail=20 tests examples

exit 0