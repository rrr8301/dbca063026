#!/bin/bash
set -e

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

# Install gvisor (using container image)
echo "Installing gvisor..."
if command -v docker &> /dev/null; then
    docker create --name temp-runsc gristlabs/gvisor-unprivileged:buster /bin/true 2>/dev/null || true
    sudo docker cp temp-runsc:/runsc /usr/bin/runsc 2>/dev/null || echo "Warning: Could not install runsc via Docker"
    docker rm temp-runsc 2>/dev/null || true
else
    echo "Warning: Docker not available. Skipping gvisor installation."
fi

# Build Node.js code
echo "Building Node.js code..."
yarn run build

# Install Chrome and chromedriver
echo "Installing Chrome and chromedriver..."
if [ -f buildtools/install_chrome_for_tests.sh ]; then
    bash buildtools/install_chrome_for_tests.sh -y
else
    echo "Warning: install_chrome_for_tests.sh not found."
fi

# Run main tests
echo "Running Mocha webdriver tests..."
export GREP_TESTS="^[A-D]"
export MOCHA_WEBDRIVER_SKIP_CLEANUP=1
export MOCHA_WEBDRIVER_HEADLESS=1

TEST_FAILED=0
yarn run test:nbrowser --parallel --jobs 3 || TEST_FAILED=1

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