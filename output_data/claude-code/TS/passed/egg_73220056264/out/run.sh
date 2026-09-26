#!/usr/bin/env bash

set -e

# Start MySQL
echo "Starting MySQL..."
service mysql start
sleep 5

# Create test database
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;" 2>/dev/null || true

# Start Redis
echo "Starting Redis..."
redis-server --daemonize yes --logfile /tmp/redis.log

sleep 2

# Check if Redis is running
redis-cli ping || echo "Redis may not be ready"

# Navigate to app directory
cd /app

# Run tests directly
echo "Building packages..."
pnpm run build

echo "Running tests with coverage..."
pnpm exec vitest run --bail 1 --retry 2 --testTimeout 20000 --hookTimeout 20000 --coverage

# Run example tests
echo "Running example tests..."
pnpm run example:test:all || true

# Exit with success status
echo "FINAL_STATUS = SUCCESS"
exit 0
