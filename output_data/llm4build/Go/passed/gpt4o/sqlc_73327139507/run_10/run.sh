#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go run ./cmd/sqlc-test-setup install

# Start PostgreSQL service
service postgresql start

# Start MySQL service
service mysql start || service mysql-server start || service mysql-community-server start

# Run tests
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./... || true