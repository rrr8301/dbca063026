#!/bin/bash
set -e

# Activate login shell environment
shopt -s login_shell

# Set up environment variables
export RUNNER_OS="ubuntu-22.04"
export PYTHON_VERSION="3.11"
export PYTHON_SUBVERSION="11"
export SINGLE_ACTION_CONFIG="False"
export USE_OPENMP="False"

# Ensure uv is in PATH
export PATH="/root/.cargo/bin:$PATH"

# Handle MOSEK license if provided
if [ -n "$MOSEK_CI_BASE64" ]; then
    echo "$MOSEK_CI_BASE64" | base64 -d > mosek.lic
    export MOSEKLM_LICENSE_FILE="$(realpath mosek.lic)"
fi

# Navigate to workspace
cd /workspace

# Install dependencies using the CI script
if [ -f "continuous_integration/install_dependencies.sh" ]; then
    echo "Running install_dependencies.sh..."
    source continuous_integration/install_dependencies.sh
else
    echo "Warning: continuous_integration/install_dependencies.sh not found"
fi

# Run tests using the CI script
if [ -f "continuous_integration/test_script.sh" ]; then
    echo "Running test_script.sh..."
    source continuous_integration/test_script.sh
else
    echo "Error: continuous_integration/test_script.sh not found"
    exit 1
fi

echo "Build and tests completed successfully!"