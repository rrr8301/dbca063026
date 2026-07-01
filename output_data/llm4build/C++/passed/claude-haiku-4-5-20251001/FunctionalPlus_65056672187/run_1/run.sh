#!/bin/bash
set -e

# Add host tools to PATH (simulating the GitHub Actions step)
export PATH="/host_usr_local/bin:$PATH"

# Run setup script
echo "Running setup..."
bash script/ci_setup_linux.sh

# Run build and tests
echo "Running tests..."
bash script/ci.sh run_tests

echo "Build and tests completed successfully!"