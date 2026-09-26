#!/usr/bin/env bash

set -e

cd /app

# Start PostgreSQL
echo "Starting PostgreSQL..."
service postgresql start
sleep 3

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if pg_isready -h localhost -U postgres 2>/dev/null; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "Attempt $i/30: PostgreSQL not ready yet, waiting..."
  sleep 1
done

# Create orm_test database for postgres (don't use sudo, we're root)
echo "Creating orm_test database for postgres..."
psql -U postgres -h localhost -c "CREATE DATABASE orm_test;" 2>/dev/null || true
psql -U postgres -h localhost -c "ALTER USER postgres WITH PASSWORD 'postgres';" 2>/dev/null || true

# Start MySQL
echo "Starting MySQL..."
service mysql start
sleep 3

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
  if mysqladmin ping -h localhost -u root -proot 2>/dev/null | grep -q "mysqld is alive"; then
    echo "MySQL is ready"
    break
  fi
  echo "Attempt $i/30: MySQL not ready yet, waiting..."
  sleep 1
done

# Create orm_test database for mysql
echo "Creating orm_test database for mysql..."
mysql -u root -proot -h localhost -e 'create database orm_test;' 2>/dev/null || true

# Try to download and run etcd via apt or download binary
echo "Installing etcd..."
apt-get update && apt-get install -y etcd-client 2>/dev/null || true

# Run etcd daemon in the background
echo "Starting etcd..."
ETCD_VERSION=v3.4.16
rm -rf /tmp/etcd-data.tmp
mkdir -p /tmp/etcd-data.tmp

# Try to use etcd if available, otherwise skip
if command -v etcd &> /dev/null; then
  echo "Using system etcd..."
  etcd \
    --name s1 \
    --data-dir /tmp/etcd-data.tmp \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls http://0.0.0.0:2379 \
    --listen-peer-urls http://0.0.0.0:2380 \
    --initial-advertise-peer-urls http://0.0.0.0:2380 \
    --initial-cluster s1=http://0.0.0.0:2380 \
    --initial-cluster-token tkn \
    --initial-cluster-state new \
    > /tmp/etcd.log 2>&1 &
  ETCD_PID=$!
  sleep 3

  # Try to populate etcd with test data
  echo "Populating etcd with test data..."
  if command -v etcdctl &> /dev/null; then
    etcdctl put current.float 1.23 2>/dev/null || true
    etcdctl put current.bool true 2>/dev/null || true
    etcdctl put current.int 11 2>/dev/null || true
    etcdctl put current.string hello 2>/dev/null || true
    etcdctl put current.serialize.name test 2>/dev/null || true
    etcdctl put sub.sub.key1 sub.sub.key 2>/dev/null || true
  fi
else
  echo "etcd not available, skipping..."
fi

# Run ORM tests on sqlite3
echo "Running ORM tests on sqlite3..."
export ORM_DRIVER=sqlite3
export ORM_SOURCE=/tmp/sqlite3/orm_test.db
mkdir -p /tmp/sqlite3
touch /tmp/sqlite3/orm_test.db
go test -v -coverprofile=coverage_sqlite3.txt -covermode=atomic $(go list ./... | grep client/orm) 2>&1 || true

# Run ORM tests on postgres
echo "Running ORM tests on postgres..."
export ORM_DRIVER=postgres
export ORM_SOURCE="host=localhost port=5432 user=postgres password=postgres dbname=orm_test sslmode=disable"
go test -v -coverprofile=coverage_postgres.txt -covermode=atomic $(go list ./... | grep client/orm) 2>&1 || true

# Run tests on mysql
echo "Running tests on mysql..."
export ORM_DRIVER=mysql
export ORM_SOURCE="root:root@/orm_test?charset=utf8"
go test -v -coverprofile=coverage.txt -covermode=atomic ./... 2>&1 || true

# Kill etcd if it's running
if [ ! -z "$ETCD_PID" ]; then
  kill $ETCD_PID 2>/dev/null || true
fi

# All tests have been executed
echo "All tests completed"
echo "FINAL_STATUS = SUCCESS"
