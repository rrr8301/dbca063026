#!/bin/bash
set -e

# Navigate to repository directory
cd /workspace/repo

# Upgrade setuptools with --break-system-packages flag
python3.11 -m pip install --upgrade --break-system-packages --force-reinstall setuptools

# Install dependencies with develop, gmpy2, gmp, and ci extras
python3.11 -m pip install --upgrade --break-system-packages ".[develop,gmpy2,gmp,ci]"

# Run pytest with auto parallelization
python3.11 -m pytest -n auto