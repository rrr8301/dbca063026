#!/bin/bash

set -e

# Set environment variables for tests
export API_URL="http://127.0.0.1:8288"
export INNGEST_EVENT_KEY="test"
export INNGEST_SIGNING_KEY="7468697320697320612074657374206b6579"
export INNGEST_DEV="http://127.0.0.1:8288"
export TEST_MODE="true"
export TEST_DATABASE="postgres"
export EXPERIMENTAL_KEY_QUEUES_ENABLE="true"
export GOCOVERDIR="coverage"

# Start PostgreSQL service
echo "Starting PostgreSQL service..."
service postgresql start

# Wait for PostgreSQL to be ready
echo "Checking PostgreSQL connectivity..."
POSTGRES_READY=false
for i in $(seq 1 30); do
    if pg_isready -h localhost -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        POSTGRES_READY=true
        break
    fi
    if [ "$i" -lt "30" ]; then
        echo "Waiting for PostgreSQL... (attempt $i/30)"
        sleep 1
    fi
done

if [ "$POSTGRES_READY" = "false" ]; then
    echo "ERROR: PostgreSQL failed to start"
    exit 1
fi

# Create test database
echo "Creating test database..."
sudo -u postgres createdb inngest_test 2>/dev/null || true

# Ensure submodules are properly initialized
echo "Initializing git submodules..."
git submodule update --init --recursive 2>/dev/null || true

# Build dev server with coverage
echo "Building dev server..."
go build -cover -o ./inngest-bin ./cmd

# Install tools
echo "Installing tools..."
go install ./cmd/tool

# Create coverage directory
mkdir -p "$GOCOVERDIR"

# Run dev server in background
echo "Running dev server..."
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@localhost:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
DEV_SERVER_PID=$!
echo "Dev server started with PID: $DEV_SERVER_PID"

# Wait for dev server to be ready
echo "Waiting for dev server to start..."
for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:8288/dev > /dev/null 2>&1; then
        echo "Dev server is ready"
        break
    fi
    if [ "$i" = "30" ]; then
        echo "WARNING: Dev server health check failed after 30 seconds, but continuing..."
        cat /tmp/dev-output.txt
    fi
    sleep 1
done

# Run E2E tests (split 4 of 5)
echo "Running E2E tests (split 4 of 5)..."
gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1

# Capture test exit code
TEST_EXIT_CODE=$?

# Clean up
echo "Cleaning up..."
kill $DEV_SERVER_PID 2>/dev/null || true
wait $DEV_SERVER_PID 2>/dev/null || true

# Print dev server logs if tests failed
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "=== Dev Server Output ==="
    cat /tmp/dev-output.txt
fi

# Exit with test result
exit $TEST_EXIT_CODE