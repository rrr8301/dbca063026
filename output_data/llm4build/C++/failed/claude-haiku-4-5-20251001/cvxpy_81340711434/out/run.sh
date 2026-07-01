#!/bin/bash
set -e

# Activate bash login shell behavior
shopt -s login_shell

# Set environment variables
export PYTHON_VERSION="3.11"
export PYTHON_SUBVERSION="11"
export RUNNER_OS="ubuntu-22.04"
export SINGLE_ACTION_CONFIG="False"
export USE_OPENMP="False"

# Handle MOSEK license (if provided via build arg or env var)
# Note: In a local build, you would need to provide MOSEK_CI_BASE64 as a build argument
# For now, we'll create a placeholder or skip if not available
if [ -n "$MOSEK_CI_BASE64" ]; then
    echo "$MOSEK_CI_BASE64" | base64 -d > mosek.lic
    export MOSEKLM_LICENSE_FILE="$(realpath mosek.lic)"
else
    echo "Warning: MOSEK_CI_BASE64 not provided. MOSEK tests may fail."
fi

# Navigate to workspace
cd /workspace

# Install dependencies using the project's install script
echo "Installing dependencies..."
source continuous_integration/install_dependencies.sh

# Run tests using the project's test script
echo "Running tests..."
source continuous_integration/test_script.sh

echo "Build and tests completed successfully!"