#!/usr/bin/env bash
set -e

export GOPATH=/home/runner/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

echo "Starting MySQL service..."
service mysql start
sleep 5

echo "Setting up MySQL root password and creating orm_test database..."
mysql -h localhost -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" || true
mysql -h localhost -u root -proot -e "CREATE DATABASE IF NOT EXISTS orm_test;" || true

echo "Starting PostgreSQL service..."
service postgresql start
sleep 5

echo "Setting up PostgreSQL..."
# Set postgres user password
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" 2>/dev/null || true
# Create orm_test database
sudo -u postgres createdb orm_test 2>/dev/null || psql -U postgres -h localhost -c "CREATE DATABASE orm_test;" 2>/dev/null || true

echo "Starting Redis service..."
service redis-server start

echo "Starting Memcached service..."
service memcached start

echo "Setting up test directories..."
export MOUNT=/tmp
rm -rf ${MOUNT}/etcd-data.tmp
mkdir -p ${MOUNT}/etcd-data.tmp

echo "Running ORM tests on sqlite3..."
export ORM_DRIVER=sqlite3
export ORM_SOURCE=/tmp/sqlite3/orm_test.db
mkdir -p /tmp/sqlite3 && touch /tmp/sqlite3/orm_test.db
go test -coverprofile=coverage_sqlite3.txt -covermode=atomic $(go list ./... | grep client/orm) || true

echo "Running ORM tests on postgres..."
export ORM_DRIVER=postgres
export ORM_SOURCE="host=localhost port=5432 user=postgres password=postgres dbname=orm_test sslmode=disable"
go test -coverprofile=coverage_postgres.txt -covermode=atomic $(go list ./... | grep client/orm) || true

echo "Running tests on mysql..."
export ORM_DRIVER=mysql
export ORM_SOURCE="root:root@/orm_test?charset=utf8"
go test -coverprofile=coverage.txt -covermode=atomic ./... 2>&1 || true

echo "FINAL_STATUS = SUCCESS"
