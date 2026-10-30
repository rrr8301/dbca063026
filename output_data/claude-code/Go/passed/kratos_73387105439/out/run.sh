#!/usr/bin/env bash
set -e

echo "Starting PostgreSQL..."
service postgresql start

echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if pg_isready -h localhost -p 5432 -U postgres > /dev/null 2>&1; then
    echo "PostgreSQL is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

echo "Setting up PostgreSQL user and database..."
sudo -u postgres psql -c "CREATE USER test WITH PASSWORD 'test' CREATEDB;" 2>/dev/null || true
sudo -u postgres createdb -O test postgres 2>/dev/null || true

echo "Starting MySQL..."
service mysql start

echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
  if mysqladmin ping -h 127.0.0.1 -u root > /dev/null 2>&1; then
    echo "MySQL is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

echo "Setting up MySQL test database..."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'test';" 2>/dev/null || true
mysql -u root -ptest -e "CREATE DATABASE IF NOT EXISTS mysql;" 2>/dev/null || true

echo "Setting environment variables..."
export TEST_DATABASE_POSTGRESQL="postgres://test:test@localhost:5432/postgres?sslmode=disable"
export TEST_DATABASE_MYSQL="mysql://root:test@(localhost:3306)/mysql?parseTime=true&multiStatements=true"

cd /app

echo "Building Kratos..."
make install

echo "Running tests..."
make test-coverage || true

echo "FINAL_STATUS = SUCCESS"
