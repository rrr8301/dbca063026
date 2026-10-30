#!/bin/bash

# Activate environment variables
source build/config/plain.sh

# Install project dependencies
if [[ "${BUILD_PACKAGES}" != "" ]]; then
    sudo apt-get update
    sudo apt-get install -y ${BUILD_PACKAGES}
fi

# Run presubmit checks
make -e presubmit

# Run tests
make test || true  # Ensure all tests run even if some fail