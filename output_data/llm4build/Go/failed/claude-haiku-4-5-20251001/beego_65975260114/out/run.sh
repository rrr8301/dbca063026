#!/bin/bash
set -e

# Create necessary directories
mkdir -p /tmp/sqlite3
mkdir -p /tmp/etcd-data.tmp
touch /tmp/sqlite3/orm_test.db

# Start Redis
echo "Starting Redis..."
redis-server --daemonize yes --port 6379

# Start Memcached (with -u flag for root user)
echo "Starting Memcached..."
memcached -d -u root -p 11211

# Start PostgreSQL
echo "Starting PostgreSQL..."
service postgresql start
sleep 5

# Create PostgreSQL test database
su - postgres -c "psql -c 'CREATE DATABASE orm_test;'" || true

# Start MySQL
echo "Starting MySQL..."
service mysql start
sleep 5

# Create MySQL test database
mysql -u root -e 'create database orm_test;' || true

# Change to workspace
cd /workspace

# Run ORM tests on sqlite3
echo "Running ORM tests on sqlite3..."
export GOPATH=/home/runner/go
export ORM_DRIVER=sqlite3
export ORM_SOURCE=/tmp/sqlite3/orm_test.db
go test -coverprofile=coverage_sqlite3.txt -covermode=atomic $(go list ./... | grep client/orm) || true

# Run ORM tests on postgres
echo "Running ORM tests on postgres..."
export ORM_DRIVER=postgres
export ORM_SOURCE="host=localhost port=5432 user=postgres password=postgres dbname=orm_test sslmode=disable"
go test -coverprofile=coverage_postgres.txt -covermode=atomic $(go list ./... | grep client/orm) || true

# Run tests on mysql
echo "Running tests on mysql..."
export ORM_DRIVER=mysql
export ORM_SOURCE="root@/orm_test?charset=utf8"
go test -coverprofile=coverage.txt -covermode=atomic ./... || true

echo "All tests completed!"