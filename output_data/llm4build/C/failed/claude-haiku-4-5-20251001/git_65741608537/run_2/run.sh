#!/bin/bash

set -e

# Enable error handling but continue on test failures
trap 'echo "Script encountered an error"' ERR

# Change to repo directory
cd /repo

# Set GitHub Actions environment variables for CI scripts
export GITHUB_ACTIONS=true
export CI=true

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

# Configure sudo for builder user to run without password
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder

# Run build and tests as builder user
echo "Running build and tests..."
if [ -f ci/run-build-and-tests.sh ]; then
    # Use su instead of sudo to avoid sudo-rs permission issues
    su - builder -c "cd /repo && bash ci/run-build-and-tests.sh"
    BUILD_EXIT_CODE=$?
else
    echo "Warning: ci/run-build-and-tests.sh not found, skipping build and tests"
    BUILD_EXIT_CODE=0
fi

# Print test failures if they exist
if [ -f ci/print-test-failures.sh ] && [ -n "$FAILED_TEST_ARTIFACTS" ]; then
    echo "Printing test failures..."
    su - builder -c "cd /repo && bash ci/print-test-failures.sh" || true
fi

# Exit with the build status
exit $BUILD_EXIT_CODE