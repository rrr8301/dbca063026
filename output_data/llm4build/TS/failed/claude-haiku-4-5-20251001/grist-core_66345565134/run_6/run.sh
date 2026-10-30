#!/bin/bash
set -e

# Create necessary directories
mkdir -p /tmp/test-logs/webdriver
export MOCHA_WEBDRIVER_LOGDIR=/tmp/test-logs/webdriver
export TESTDIR=/tmp/test-logs
export GVISOR_FLAGS="-unprivileged -ignore-cgroups"
export GVISOR_EXTRA_DIRS=/opt

# Set database connection defaults if not already set
export POSTGRES_HOST=${POSTGRES_HOST:-localhost}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
export POSTGRES_USER=${POSTGRES_USER:-db_user}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-db_password}
export POSTGRES_DB=${POSTGRES_DB:-db_name}

export REDIS_HOST=${REDIS_HOST:-localhost}
export REDIS_PORT=${REDIS_PORT:-6379}

export MINIO_HOST=${MINIO_HOST:-localhost}
export MINIO_PORT=${MINIO_PORT:-9000}
export MINIO_ROOT_USER=${MINIO_ROOT_USER:-administrator}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-administrator}

# Install Python virtualenv
echo "Installing Python virtualenv..."
pip install virtualenv

# Install Python packages via yarn
echo "Installing Python packages..."
yarn run install:python || { echo "Failed to install Python packages"; exit 1; }

# Install Node.js packages
echo "Installing Node.js packages..."
yarn install || { echo "Failed to install Node.js packages"; exit 1; }

# Build Node.js code
echo "Building Node.js code..."
yarn run build || { echo "Failed to build Node.js code"; exit 1; }

# Install Chrome and chromedriver
echo "Installing Chrome and chromedriver..."
if [ -f buildtools/install_chrome_for_tests.sh ]; then
    bash buildtools/install_chrome_for_tests.sh -y || { echo "Failed to install Chrome"; exit 1; }
else
    echo "Error: install_chrome_for_tests.sh not found."
    exit 1
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
find "$TESTDIR" -iname "*.socket" -delete 2>/dev/null || true

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Test suite failed."
    exit 1
else
    echo "Test suite passed."
    exit 0
fi