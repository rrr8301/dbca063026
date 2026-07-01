#!/bin/bash
set -e

# Start Redis service
echo "Starting Redis..."
redis-server --daemonize yes --port 6379

# Start MySQL service
echo "Starting MySQL..."
service mysql start

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
  if mysql -uroot -e "SELECT 1" &>/dev/null; then
    echo "MySQL is ready"
    break
  fi
  echo "Attempt $i: MySQL not ready yet, waiting..."
  sleep 1
done

# Initialize database
echo "Initializing database..."
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;"

# Install dependencies
echo "Installing pnpm dependencies..."
pnpm install --frozen-lockfile

# Run tests
echo "Running tests with shard 3/3..."
pnpm run ci --shard=3/3

echo "Tests completed successfully!"