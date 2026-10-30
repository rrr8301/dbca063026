#!/bin/bash
set -e

# Set environment variables
export ARCH_ON_CI="normal"
export IS_CRON="false"
export PY_COLORS="1"

# Ensure we're in the workspace
cd /workspace

# Run tests with tox
python -m tox -e py312-test-alldeps-fitsio -v --develop -- -n=4 --run-slow