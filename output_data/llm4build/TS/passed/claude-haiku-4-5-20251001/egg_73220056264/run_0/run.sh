#!/bin/bash

set -e

# Enable error handling but continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "Starting services..."
echo "=========================================="

# Start Redis
echo "Starting Redis server..."
redis-server --daemonize yes --port 6379
sleep 2

# Start MySQL
echo "Starting MySQL server..."
service mysql start
sleep 5

# Initialize database
echo "Initializing database..."
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;" || true

echo "=========================================="
echo "Installing project dependencies..."
echo "=========================================="

# Install dependencies using utoo and pnpm
ut install --from pnpm

echo "=========================================="
echo "Running tests with coverage..."
echo "=========================================="

# Run CI tests
ut run ci || TEST_FAILED=1

echo "=========================================="
echo "Running example tests..."
echo "=========================================="

# Run example tests
ut run example:test:all || TEST_FAILED=1

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

# Exit with failure code if any tests failed
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0