#!/bin/bash

source /venv/bin/activate

# Install project dependencies
pip install --index-url=https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple .[minimum-jaxlib] -r build/test-requirements.txt

# Set environment variables for tests
export JAX_NUM_GENERATED_CASES=1
export JAX_ENABLE_X64=0
export JAX_ENABLE_CUSTOM_PRNG=0
export JAX_THREEFRY_PARTITIONABLE=0
export JAX_ENABLE_CHECKS=true
export JAX_SKIP_SLOW_TESTS=true
export PY_COLORS=1

# Run tests
pytest -n auto --tb=short --maxfail=20 tests examples