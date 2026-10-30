#!/bin/bash
set -e

# Exit on any error but continue running tests
set +e
TEST_FAILED=0

# Create necessary directories
mkdir -p /tmp/test-logs/webdriver
export MOCHA_WEBDRIVER_LOGDIR=/tmp/test-logs/webdriver
export TESTDIR=/tmp/test-logs
export GVISOR_FLAGS="-unprivileged -ignore-cgroups"
export GVISOR_EXTRA_DIRS=/opt

# Install Python virtualenv
echo "Installing Python virtualenv..."
pip install virtualenv

# Install Python packages via yarn
echo "Installing Python packages..."
yarn run install:python

# Install Node.js packages
echo "Installing Node.js packages..."
yarn install

# Attempt to install gvisor (download binary directly)
echo "Installing gvisor..."
mkdir -p /tmp/gvisor-download
cd /tmp/gvisor-download
if curl -L -o runsc https://storage.googleapis.com/gvisor/releases/release/latest/x86_64/runsc 2>/dev/null; then
    chmod +x runsc
    sudo mv runsc /usr/bin/runsc || mv runsc /usr/bin/runsc 2>/dev/null || echo "Warning: Could not install runsc to /usr/bin"
else
    echo "Warning: Could not download gvisor runsc binary. Tests may fail if gvisor is required."
fi
cd /workspace

# Build Node.js code
echo "Building Node.js code..."
yarn run build

# Install Chrome and chromedriver
echo "Installing Chrome and chromedriver..."
if [ -f buildtools/install_chrome_for_tests.sh ]; then
    bash buildtools/install_chrome_for_tests.sh -y
else
    echo "Warning: install_chrome_for_tests.sh not found. Using system chromium-browser and chromedriver."
fi

# Run main tests
echo "Running Mocha webdriver tests..."
export GREP_TESTS="^[A-D]"
export MOCHA_WEBDRIVER_SKIP_CLEANUP=1
export MOCHA_WEBDRIVER_HEADLESS=1

yarn run test:nbrowser --parallel --jobs 3
if [ $? -ne 0 ]; then
    TEST_FAILED=1
    echo "Tests failed with exit code $?"
fi

# Cleanup socket files
echo "Cleaning up socket files..."
find $TESTDIR -iname "*.socket" -exec rm {} \; 2>/dev/null || true

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Test suite failed."
    exit 1
else
    echo "Test suite passed."
    exit 0
fi