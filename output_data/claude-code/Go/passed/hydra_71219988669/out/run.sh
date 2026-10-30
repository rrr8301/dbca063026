#!/usr/bin/env bash
set -e

# Install PostgreSQL and MySQL servers
echo "Installing PostgreSQL and MySQL..."
apt-get update && apt-get install -y \
    postgresql postgresql-contrib \
    mysql-server \
    && rm -rf /var/lib/apt/lists/*

# Start PostgreSQL service
echo "Starting PostgreSQL..."
service postgresql start || true
sleep 3

# Set PostgreSQL password
echo "Configuring PostgreSQL..."
su - postgres -c "psql -U postgres -c \"ALTER USER postgres WITH PASSWORD 'secret';\"" 2>/dev/null || true

# Start MySQL service
echo "Starting MySQL..."
service mysql start || true
sleep 3

# Configure MySQL
echo "Configuring MySQL..."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'secret'; FLUSH PRIVILEGES;" 2>/dev/null || true

# Start CockroachDB in background
echo "Starting CockroachDB..."
cockroach start-single-node --insecure --listen-addr=0.0.0.0:26257 --advertise-addr=localhost:26257 > /tmp/cockroach.log 2>&1 &
COCKROACH_PID=$!
sleep 5

# Set environment variables for databases
export TEST_DATABASE_POSTGRESQL="postgres://postgres:secret@localhost:5432/postgres?sslmode=disable"
export TEST_DATABASE_MYSQL="mysql://root:secret@(localhost:3306)/mysql?multiStatements=true&parseTime=true"
export TEST_DATABASE_COCKROACHDB="cockroach://root@localhost:26257/defaultdb?sslmode=disable"

# Change to app directory
cd /app

# Run go list for nancy
echo "Running go list..."
go list -json > go.list 2>&1 || true

# Install nancy
echo "Installing nancy..."
go install github.com/sonatype-nexus-community/nancy@v1.0.42 2>&1 || true

# Run nancy
echo "Running nancy..."
nancy sleuth -o text go.list 2>&1 || true

# Install golangci-lint
echo "Installing golangci-lint..."
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin latest 2>&1 || true

# Run golangci-lint
echo "Running golangci-lint..."
golangci-lint run --timeout 10m0s ./... 2>&1 || true

# Run go tests
echo "Running go tests..."
TEST_FAILED=false
if ! go test -coverprofile coverage.out -failfast -timeout=20m ./...; then
  TEST_FAILED=true
fi

# Cleanup
echo "Cleaning up..."
kill $COCKROACH_PID 2>/dev/null || true
wait $COCKROACH_PID 2>/dev/null || true

# Print final status
if [ "$TEST_FAILED" = "true" ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
