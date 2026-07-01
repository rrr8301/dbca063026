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

# First, connect as root without password (using socket auth) and set password
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';" || true

# Wait a moment for the change to take effect
sleep 1

# Now verify we can connect without password
echo "Verifying database access..."
mysql -uroot -e "SELECT 1;" || {
  echo "Failed to connect to MySQL, retrying..."
  sleep 2
  mysql -uroot -e "SELECT 1;" || {
    echo "Failed to connect to MySQL"
    exit 1
  }
}

# Create test database and set up grants
echo "Setting up database and permissions..."
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;" || true
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" || true
mysql -uroot -e "FLUSH PRIVILEGES;" || true

# Final verification
echo "Final database verification..."
mysql -uroot -e "SELECT 1;" || {
  echo "Failed to connect to MySQL"
  exit 1
}

# Set environment variables for MySQL connection (no password, socket auth)
export MYSQL_HOST=localhost
export MYSQL_PORT=3306
export MYSQL_USER=root
export MYSQL_PASSWORD=
export MYSQL_DB=test

# Install dependencies
echo "Installing pnpm dependencies..."
pnpm install --frozen-lockfile

# Run tests
echo "Running tests with shard 3/3..."
pnpm run ci --shard=3/3

echo "Tests completed successfully!"