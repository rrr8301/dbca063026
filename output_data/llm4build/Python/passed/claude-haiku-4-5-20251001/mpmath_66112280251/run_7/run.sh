#!/bin/bash
set -e

# Clone the repository
git clone --depth=1 https://github.com/mpmath/mpmath.git /workspace/repo
cd /workspace/repo

# Upgrade setuptools with --break-system-packages flag (skip pip as it's Debian-managed)
python3.11 -m pip install --upgrade --break-system-packages --force-reinstall setuptools

# Install dependencies with develop, gmpy2, gmp, and ci extras
python3.11 -m pip install --upgrade --break-system-packages ".[develop,gmpy2,gmp,ci]"

# Run pytest with auto parallelization
python3.11 -m pytest -n auto