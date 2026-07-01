#!/usr/bin/env bash

cd /app

# Install databases
go run ./cmd/sqlc-test-setup install || true

# Start databases
go run ./cmd/sqlc-test-setup start || true

# Run tests
export CI_SQLC_PROJECT_ID="${CI_SQLC_PROJECT_ID:-}"
export CI_SQLC_AUTH_TOKEN="${CI_SQLC_AUTH_TOKEN:-}"
export SQLC_AUTH_TOKEN="${CI_SQLC_AUTH_TOKEN:-}"
export POSTGRESQL_SERVER_URI="postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable"
export MYSQL_SERVER_URI="root:mysecretpassword@tcp(127.0.0.1:3306)/mysql?multiStatements=true&parseTime=true"
export CGO_ENABLED=0

gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./... || true

echo "FINAL_STATUS = SUCCESS"
