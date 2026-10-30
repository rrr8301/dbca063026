#!/bin/bash

# Create builder user and set permissions
useradd builder --create-home
chown -R builder /workspace

# Ensure $GITHUB_ENV is writable if it exists
if [ -n "$GITHUB_ENV" ]; then
    chmod a+w $GITHUB_ENV
fi

# Set CI environment variables
export CI=true
export GITHUB_ACTIONS=true

# Switch to builder user and run build and tests using sudo
sudo --set-home --user=builder bash -c "
    # Set additional environment variables for CI
    export TERM=dumb
    export MAKEFLAGS=

    # Check for CI environment variables
    if [ -z \"\$CI\" ] || [ -z \"\$GITHUB_ACTIONS\" ]; then
        echo 'CI environment variables are not set correctly'
        exit 1
    fi

    # Install project dependencies
    /workspace/ci/install-dependencies.sh

    # Run build and tests
    /workspace/ci/run-build-and-tests.sh

    # Print test failures if any
    if [ -n \"\$FAILED_TEST_ARTIFACTS\" ]; then
        /workspace/ci/print-test-failures.sh
    fi
"