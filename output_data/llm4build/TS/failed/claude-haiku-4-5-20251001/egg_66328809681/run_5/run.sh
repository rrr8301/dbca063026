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

# Initialize database - set up root user with proper permissions
echo "Initializing database..."

# Use mysql_upgrade to initialize the system tables properly
mysql_upgrade -uroot --silent 2>/dev/null || true

# Create test database and grant all privileges to root
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" || true
mysql -uroot -e "FLUSH PRIVILEGES;" || true

# Verify database access
echo "Verifying database access..."
mysql -uroot -e "SELECT 1;" || {
  echo "Failed to connect to MySQL"
  exit 1
}

# Install dependencies
echo "Installing pnpm dependencies..."
pnpm install --frozen-lockfile

# Run tests
echo "Running tests with shard 3/3..."
pnpm run ci --shard=3/3

echo "Tests completed successfully!"