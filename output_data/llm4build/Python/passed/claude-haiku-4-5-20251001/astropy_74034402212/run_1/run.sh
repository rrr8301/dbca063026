#!/bin/bash

set -e

# Set environment variables
export ARCH_ON_CI="normal"
export IS_CRON="false"
export PY_COLORS="1"

# Decode and create set_env.py (if needed for setup)
echo $SET_ENV_SCRIPT | base64 --decode > set_env.py 2>/dev/null || true

# Ensure we're in the workspace
cd /workspace

# Install project dependencies via tox
echo "Installing dependencies and running tests with tox..."
tox -e py312-test-cov -- --cov-report=xml:./coverage.xml

echo "Tests completed. Coverage report available at ./coverage.xml"