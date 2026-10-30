#!/bin/bash
set -e

# Clone the repository
git clone --depth=1 https://github.com/mpmath/mpmath.git /workspace/repo
cd /workspace/repo

# Upgrade pip and setuptools
pip install --upgrade setuptools pip

# Install dependencies with develop, gmpy2, gmp, and ci extras
pip install --upgrade ".[develop,gmpy2,gmp,ci]"

# Run pytest with auto parallelization
pytest -n auto