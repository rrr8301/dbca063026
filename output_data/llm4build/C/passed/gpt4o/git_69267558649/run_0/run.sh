#!/bin/bash

# Activate environment variables
export DEVELOPER=1
export CUSTOM_PATH=/custom

# Install project dependencies
./ci/install-dependencies.sh

# Create builder user and set permissions
useradd builder --create-home
chown -R builder .
chmod a+w $GITHUB_ENV

# Run build and tests as builder user
sudo --preserve-env --set-home --user=builder ./ci/run-build-and-tests.sh

# Print test failures if any
if [ $? -ne 0 ] && [ -n "$FAILED_TEST_ARTIFACTS" ]; then
    sudo --preserve-env --set-home --user=builder ./ci/print-test-failures.sh
fi