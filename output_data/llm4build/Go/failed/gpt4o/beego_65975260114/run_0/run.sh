#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export GOPATH="/home/runner/go"

# Install project dependencies
go mod download

# Run etcd setup
ETCD_VERSION=v3.4.16
rm -rf /tmp/etcd-data.tmp
mkdir -p /tmp/etcd-data.tmp
docker run -d \
  -p 2379:2379 \
  -p 2380:2380 \
  --mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
  --name etcd-gcr-${ETCD_VERSION} \
  gcr.io/etcd-development/etcd:${ETCD_VERSION} \
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
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.float 1.23"
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.bool true"
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.int 11"
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.string hello"
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put current.serialize.name test"
docker exec etcd-gcr-${ETCD_VERSION} /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put sub.sub.key1 sub.sub.key"

# Run ORM tests on sqlite3
export ORM_DRIVER=sqlite3
export ORM_SOURCE=/tmp/sqlite3/orm_test.db
mkdir -p /tmp/sqlite3 && touch /tmp/sqlite3/orm_test.db
go test -coverprofile=coverage_sqlite3.txt -covermode=atomic $(go list ./... | grep client/orm)

# Run ORM tests on postgres
export ORM_DRIVER=postgres
export ORM_SOURCE="host=localhost port=5432 user=postgres password=postgres dbname=orm_test sslmode=disable"
go test -coverprofile=coverage_postgres.txt -covermode=atomic $(go list ./... | grep client/orm)

# Run tests on mysql
export ORM_DRIVER=mysql
export ORM_SOURCE="root:root@/orm_test?charset=utf8"
service mysql start
mysql -u root -proot -e 'create database orm_test;'
go test -coverprofile=coverage.txt -covermode=atomic ./...