#!/bin/bash

set -e

# Set Go environment
export GOPATH="/root/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Change to workspace
cd /workspace

# Run ORM tests on sqlite3
echo "Running ORM tests on sqlite3..."
mkdir -p /tmp/sqlite3
touch /tmp/sqlite3/orm_test.db
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
export ORM_SOURCE="root:root@/orm_test?charset=utf8"
go test -coverprofile=coverage.txt -covermode=atomic ./... || true

echo "All tests completed!"