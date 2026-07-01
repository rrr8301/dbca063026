#!/usr/bin/env bash

set -e

# Activate virtual environment
source /app/venv/bin/activate

# Get the Python binary
PYTHON_BIN=python

# Set environment variables from the workflow (Python 3.11 build with x64 enabled)
export JAX_NUM_GENERATED_CASES=1
export JAX_ENABLE_X64=1
export JAX_ENABLE_CUSTOM_PRNG=1
export JAX_THREEFRY_PARTITIONABLE=1
export JAX_ENABLE_CHECKS=true
export JAX_SKIP_SLOW_TESTS=true
export PY_COLORS=1

echo "JAX_NUM_GENERATED_CASES=$JAX_NUM_GENERATED_CASES"
echo "JAX_ENABLE_X64=$JAX_ENABLE_X64"
echo "JAX_ENABLE_CUSTOM_PRNG=$JAX_ENABLE_CUSTOM_PRNG"
echo "JAX_THREEFRY_PARTITIONABLE=$JAX_THREEFRY_PARTITIONABLE"
echo "JAX_ENABLE_CHECKS=$JAX_ENABLE_CHECKS"
echo "JAX_SKIP_SLOW_TESTS=$JAX_SKIP_SLOW_TESTS"

# Run the tests
$PYTHON_BIN -m pytest -n auto --tb=short --maxfail=20 tests examples

echo "FINAL_STATUS = SUCCESS"
