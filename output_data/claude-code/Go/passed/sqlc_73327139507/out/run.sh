#!/usr/bin/env bash
set -e

# Start PostgreSQL
service postgresql start
sleep 3

# Start MySQL
service mysql start
sleep 3

# Install gotestsum
go install gotest.tools/gotestsum@latest

# Install sqlc-gen-test
go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0

# Install test-json-process-plugin
go install ./scripts/test-json-process-plugin/

# Install ./...
export CGO_ENABLED=0
go install ./...

# Build internal/endtoend
cd /app/internal/endtoend/testdata
go build ./...
cd /app

# Configure PostgreSQL
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" || true
sleep 2

# Configure MySQL - need to use socket access first, then set password
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mysecretpassword';" || true
sleep 2

# Run tests
export CI_SQLC_PROJECT_ID=""
export CI_SQLC_AUTH_TOKEN=""
export SQLC_AUTH_TOKEN=""
export POSTGRESQL_SERVER_URI="postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable"
export MYSQL_SERVER_URI="root:mysecretpassword@tcp(127.0.0.1:3306)/mysql?multiStatements=true&parseTime=true"
export CGO_ENABLED=0

if gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
