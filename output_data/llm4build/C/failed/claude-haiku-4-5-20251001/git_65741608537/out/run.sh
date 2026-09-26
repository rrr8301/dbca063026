#!/bin/bash

set -e

# Enable error handling but continue on test failures
trap 'echo "Script encountered an error"' ERR

# Change to repo directory
cd /repo

# Set GitHub Actions environment variables for CI scripts
export GITHUB_ACTIONS=true
export CI=true
export TERM=dumb

# Create GITHUB_ENV file
export GITHUB_ENV=/tmp/github_env
touch $GITHUB_ENV
chmod a+w $GITHUB_ENV

# Install dependencies using the project's script
echo "Installing dependencies..."
if [ -f ci/install-dependencies.sh ]; then
    bash ci/install-dependencies.sh
else
    echo "Warning: ci/install-dependencies.sh not found, skipping dependency installation"
fi

# Create builder user if not already exists
if ! id -u builder > /dev/null 2>&1; then
    useradd builder --create-home
fi

# Change ownership to builder user
chown -R builder /repo
chown builder $GITHUB_ENV

# Configure sudo for builder user to run without password
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder

# Run build and tests as builder user
echo "Running build and tests..."
if [ -f ci/run-build-and-tests.sh ]; then
    # Run as builder user using su with environment variables preserved
    # Export all current environment variables for the subshell
    su - builder -c "
        export GITHUB_ACTIONS='$GITHUB_ACTIONS'
        export CI='$CI'
        export TERM='$TERM'
        export GITHUB_ENV='$GITHUB_ENV'
        export DEVELOPER='$DEVELOPER'
        export CC='$CC'
        export CUSTOM_PATH='$CUSTOM_PATH'
        export PATH='$PATH'
        cd /repo
        bash ci/run-build-and-tests.sh
    "
    BUILD_EXIT_CODE=$?
else
    echo "Warning: ci/run-build-and-tests.sh not found, skipping build and tests"
    BUILD_EXIT_CODE=0
fi

# Print test failures if they exist
if [ -f ci/print-test-failures.sh ] && [ -n "$FAILED_TEST_ARTIFACTS" ]; then
    echo "Printing test failures..."
    su - builder -c "
        export GITHUB_ACTIONS='$GITHUB_ACTIONS'
        export CI='$CI'
        export TERM='$TERM'
        export GITHUB_ENV='$GITHUB_ENV'
        export DEVELOPER='$DEVELOPER'
        export CC='$CC'
        export CUSTOM_PATH='$CUSTOM_PATH'
        export PATH='$PATH'
        export FAILED_TEST_ARTIFACTS='$FAILED_TEST_ARTIFACTS'
        cd /repo
        bash ci/print-test-failures.sh
    " || true
fi

# Exit with the build status
exit $BUILD_EXIT_CODE