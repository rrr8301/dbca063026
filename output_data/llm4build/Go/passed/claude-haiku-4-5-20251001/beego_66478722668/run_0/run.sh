#!/bin/bash

set -e

# Set Go environment
export GOPATH="/root/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Start PostgreSQL service
echo "Starting PostgreSQL..."
service postgresql start
sleep 2

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -U postgres; do
  echo "Waiting for PostgreSQL..."
  sleep 1
done

# Create ORM test database
sudo -u postgres psql -c "CREATE DATABASE orm_test;" || true

# Start MySQL service
echo "Starting MySQL..."
service mysql start
sleep 2

# Wait for MySQL to be ready
until mysqladmin ping -h localhost -u root 2>/dev/null; do
  echo "Waiting for MySQL..."
  sleep 1
done

# Create ORM test database for MySQL
mysql -u root -e 'CREATE DATABASE IF NOT EXISTS orm_test;'

# Start Redis
echo "Starting Redis..."
redis-server --daemonize yes --port 6379

# Start Memcached
echo "Starting Memcached..."
memcached -d -p 11211

# Run etcd
echo "Starting etcd..."
rm -rf /tmp/etcd-data.tmp
mkdir -p /tmp/etcd-data.tmp

# Download and run etcd (using docker if available, otherwise skip)
if command -v docker &> /dev/null; then
  docker run -d \
    -p 2379:2379 \
    -p 2380:2380 \
    --mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
    --name etcd-gcr-v3.4.16 \
    gcr.io/etcd-development/etcd:v3.4.16 \
    /usr/local/bin/etcd \
    --name s1 \
    --data-dir /etcd-data \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls http://0.0.0.0:2379 \
    --listen-peer-urls http://0.0.0.0:2380 \
    --initial-advertise-peer-urls http://0.0.0.0:2380 \
    --initial-cluster s1=http://0.0.0.0:2380 \
    --initial-cluster-token tkn \
    --initial-cluster-state new
  
  sleep 2
  
  # Populate etcd with test data
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.float 1.23"
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.bool true"
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.int 11"
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.string hello"
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.serialize.name test"
  docker exec etcd-gcr-v3.4.16 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put sub.sub.key1 sub.sub.key"
else
  echo "Docker not available, skipping etcd setup"
fi

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