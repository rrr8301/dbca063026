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
for i in {1..60}; do
  if mysqladmin ping -uroot --silent 2>/dev/null; then
    echo "MySQL is ready"
    break
  fi
  echo "Attempt $i: MySQL not ready yet, waiting..."
  sleep 1
done

# Initialize database - use socket authentication (no password needed for root via socket)
echo "Initializing database..."
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;" 2>/dev/null || true

# Ensure root user can connect without password via socket
echo "Configuring MySQL root user..."
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;" 2>/dev/null || true
mysql -uroot -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Install dependencies
echo "Installing pnpm dependencies..."
pnpm install --frozen-lockfile

# Run tests
echo "Running tests with shard 3/3..."
pnpm run ci --shard=3/3

echo "Tests completed successfully!"