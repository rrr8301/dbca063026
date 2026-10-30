#!/usr/bin/env bash

set -e

# Start PostgreSQL
echo "Starting PostgreSQL..."
service postgresql start || true
sleep 2

# Create PostgreSQL user and database
sudo -u postgres psql -c "CREATE USER test WITH PASSWORD 'test' CREATEDB;" || true
sudo -u postgres psql -c "ALTER USER test CREATEDB;" || true
sudo -u postgres psql -c "CREATE DATABASE postgres OWNER test;" || true

# Start MySQL
echo "Starting MySQL..."
service mysql start || true
sleep 2

# Set MySQL root password
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'test';" || true
mysql -uroot -ptest -e "CREATE DATABASE IF NOT EXISTS mysql;" || true

# Start CockroachDB
echo "Starting CockroachDB..."
cockroach start-single-node --insecure --listen-addr=localhost:26257 --background || true
sleep 3

# Wait for services to be ready
echo "Waiting for services to be ready..."
for i in {1..30}; do
  if nc -z localhost 5432 2>/dev/null && \
     nc -z localhost 3306 2>/dev/null && \
     nc -z localhost 26257 2>/dev/null; then
    echo "All services are ready!"
    break
  fi
  echo "Waiting for services... ($i/30)"
  sleep 1
done

# Export environment variables for tests
export TEST_DATABASE_POSTGRESQL="postgres://test:test@localhost:5432/postgres?sslmode=disable"
export TEST_DATABASE_MYSQL="mysql://root:test@localhost:3306/mysql?parseTime=true&multiStatements=true"
export TEST_DATABASE_COCKROACHDB="cockroach://root@localhost:26257/defaultdb?sslmode=disable"

# Run the tests
echo "Running tests..."
cd /app
make install || true
make test-coverage

echo "FINAL_STATUS = SUCCESS"
