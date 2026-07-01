#!/bin/bash
set -e

# Install tools from the project
go install ./cmd/...

# Start PostgreSQL service
echo "Starting PostgreSQL..."
service postgresql start

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        break
    fi
    if [ "$i" = "30" ]; then
        echo "ERROR: PostgreSQL failed to start"
        exit 1
    fi
    sleep 1
done

# Create test database
echo "Creating test database..."
sudo -u postgres psql -c "CREATE DATABASE inngest_test;" || true

echo "Setup complete. Ready for tests."