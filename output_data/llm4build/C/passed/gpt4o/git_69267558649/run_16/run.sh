#!/bin/bash

# Activate environment variables
export DEVELOPER=1
export CUSTOM_PATH=/custom

# Set a default CI type if not set
export CI_TYPE=${CI_TYPE:-"local"}

# Debugging: Print the CI_TYPE to ensure it's set correctly
echo "CI_TYPE is set to: $CI_TYPE"

# Install project dependencies
./ci/install-dependencies.sh

# Check if the builder user already exists before adding
if ! id "builder" &>/dev/null; then
    useradd builder --create-home
fi

# Set permissions for the builder user
chown -R builder .

# Ensure $GITHUB_ENV is writable if it exists
if [ -n "$GITHUB_ENV" ]; then
    chmod a+w $GITHUB_ENV
fi

# Run build and tests as builder user
sudo --preserve-env=DEVELOPER,CUSTOM_PATH,CI_TYPE --set-home --user=builder ./ci/run-build-and-tests.sh

# Check if the build and tests were successful
if [ $? -ne 0 ]; then
    # Print test failures if any
    if [ -n "$FAILED_TEST_ARTIFACTS" ]; then
        sudo --preserve-env=DEVELOPER,CUSTOM_PATH,CI_TYPE --set-home --user=builder ./ci/print-test-failures.sh
    fi
    exit 1
fi