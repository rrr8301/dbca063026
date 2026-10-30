#!/bin/bash

set -e

# Configuration
NODE_VERSION="20.19.4"
NO_LOCKFILE="true"
MAX_ATTEMPTS=3

echo "=========================================="
echo "Metro Test Suite"
echo "=========================================="
echo "Node Version: $(node --version)"
echo "Yarn Version: $(yarn --version)"
echo "No Lockfile: $NO_LOCKFILE"
echo "=========================================="

# Install dependencies
echo ""
echo "Installing dependencies..."
if [ "$NO_LOCKFILE" = "true" ]; then
    echo "Using --no-lockfile flag"
    yarn install --no-lockfile --non-interactive --ignore-scripts
else
    echo "Using --frozen-lockfile flag"
    yarn install --frozen-lockfile --non-interactive --ignore-scripts
fi

echo ""
echo "Dependencies installed successfully"
echo ""

# Run Jest tests with retry logic
echo "Running Jest tests..."
echo ""

NIGHTLY_TESTS_NO_LOCKFILE="$NO_LOCKFILE"
export NIGHTLY_TESTS_NO_LOCKFILE

attempt=1
test_failed=false

until yarn jest --ci --maxWorkers 4 --reporters=default --reporters=jest-junit --rootdir='./'; do
    if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo ""
        echo "❌ Tests failed after $MAX_ATTEMPTS attempts"
        test_failed=true
        break
    fi
    echo ""
    echo "⚠️  Attempt $attempt failed, retrying..."
    attempt=$((attempt + 1))
    sleep 5
done

echo ""
echo "=========================================="
if [ "$test_failed" = true ]; then
    echo "Test Suite: FAILED"
    echo "=========================================="
    exit 1
else
    echo "Test Suite: PASSED"
    echo "=========================================="
    exit 0
fi