#!/bin/bash
set -e

# This script is for reference/local testing only.
# The actual CI/CD pipeline runs on GitHub Actions (see .github/workflows/ci.yml)

# Create necessary directories
mkdir -p /tmp/test-logs/webdriver
export MOCHA_WEBDRIVER_LOGDIR=${MOCHA_WEBDRIVER_LOGDIR:-/tmp/test-logs/webdriver}
export TESTDIR=${TESTDIR:-/tmp/test-logs}
export GVISOR_FLAGS="${GVISOR_FLAGS:--unprivileged -ignore-cgroups}"
export GVISOR_EXTRA_DIRS="${GVISOR_EXTRA_DIRS:-/opt}"

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

# Function to wait for service availability
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_attempts=30
    local attempt=0

    echo "Waiting for $service_name to be ready at $host:$port..."
    while [ $attempt -lt $max_attempts ]; do
        if nc -z "$host" "$port" 2>/dev/null; then
            echo "$service_name is ready!"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    echo "Warning: $service_name did not become ready within timeout"
    return 1
}

# Wait for services to be ready
wait_for_service "$POSTGRES_HOST" "$POSTGRES_PORT" "PostgreSQL" || true
wait_for_service "$REDIS_HOST" "$REDIS_PORT" "Redis" || true
wait_for_service "$MINIO_HOST" "$MINIO_PORT" "MinIO" || true

# Install Python virtualenv
echo "Installing Python virtualenv..."
pip install --quiet virtualenv

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

# Run main tests - all test cases without skipping
echo "Running Mocha webdriver tests..."
export GREP_TESTS="${GREP_TESTS:-^[A-D]}"
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