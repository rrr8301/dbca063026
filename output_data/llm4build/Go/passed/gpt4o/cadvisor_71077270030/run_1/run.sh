#!/bin/bash

# Activate environment variables
source build/config/plain.sh

# Install project dependencies
if [[ "${BUILD_PACKAGES}" != "" ]]; then
    apt-get update
    apt-get install -y ${BUILD_PACKAGES}
fi

# Run presubmit checks
make -e presubmit

# Run tests
make test  # Ensure all tests run