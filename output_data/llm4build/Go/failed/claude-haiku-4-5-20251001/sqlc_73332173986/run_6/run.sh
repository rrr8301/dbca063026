#!/bin/bash
set -e

# Navigate to the workspace (repository root)
cd /workspace

# Install gotestsum
echo "Installing gotestsum..."
go install gotest.tools/gotestsum@latest

# Install sqlc-gen-test
echo "Installing sqlc-gen-test..."
go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0

# Install test-json-process-plugin
echo "Installing test-json-process-plugin..."
go install ./scripts/test-json-process-plugin/

# Install project dependencies
echo "Installing project dependencies..."
CGO_ENABLED=0 go install ./...

# Build internal/endtoend testdata
echo "Building internal/endtoend testdata..."
cd /workspace/internal/endtoend/testdata
CGO_ENABLED=0 go build ./...

# Return to workspace root for database setup
cd /workspace

# Initialize PostgreSQL data directory
echo "Initializing PostgreSQL..."
sudo mkdir -p /var/run/postgresql
sudo chown postgres:postgres /var/run/postgresql
sudo chmod 2775 /var/run/postgresql
sudo -u postgres initdb -D /var/lib/postgresql/data || true

# Start PostgreSQL
echo "Starting PostgreSQL..."
sudo service postgresql start || sudo -u postgres /usr/lib/postgresql/*/bin/postgres -D /var/lib/postgresql/data &
sleep 3

# Create PostgreSQL user and database
echo "Setting up PostgreSQL..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" || true
sudo -u postgres psql -c "CREATE DATABASE postgres;" || true

# Start MySQL
echo "Starting MySQL..."
sudo service mysql start || true
sleep 3

# Set MySQL root password
echo "Setting up MySQL..."
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysecretpassword';" || true
sudo mysql -u root -pmysecretpassword -e "CREATE DATABASE IF NOT EXISTS mysql;" || true

# Run tests
echo "Running tests..."
export CI_SQLC_PROJECT_ID="${CI_SQLC_PROJECT_ID:-}"
export CI_SQLC_AUTH_TOKEN="${CI_SQLC_AUTH_TOKEN:-}"
export SQLC_AUTH_TOKEN="${SQLC_AUTH_TOKEN:-}"
export POSTGRESQL_SERVER_URI="postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable"
export MYSQL_SERVER_URI="root:mysecretpassword@tcp(127.0.0.1:3306)/mysql?multiStatements=true&parseTime=true"
export CGO_ENABLED=0

gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./...

echo "Tests completed successfully!"