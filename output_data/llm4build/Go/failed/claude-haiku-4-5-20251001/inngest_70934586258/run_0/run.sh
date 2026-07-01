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

# Ensure Docker daemon is running (if not already)
if ! docker ps > /dev/null 2>&1; then
    echo "Starting Docker daemon..."
    dockerd &
    sleep 3
fi

# Start postgres container
echo "Starting PostgreSQL container..."
docker run -d --name inngest-test-postgres \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_DB=inngest_test \
    -p 5432:5432 \
    postgres:17

# Wait for postgres to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if docker exec inngest-test-postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        break
    fi
    if [ "$i" = "30" ]; then
        echo "ERROR: PostgreSQL failed to start"
        exit 1
    fi
    sleep 1
done

# Build dev server with coverage
echo "Building dev server..."
go build -cover -o ./inngest-bin ./cmd

# Install tools
echo "Installing tools..."
go install tool

# Create coverage directory
mkdir -p "$GOCOVERDIR"

# Run dev server in background
echo "Running dev server..."
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@localhost:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
DEV_SERVER_PID=$!
echo "Dev server started with PID: $DEV_SERVER_PID"

# Wait for dev server to be ready
sleep 5
echo "Checking dev server health..."
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null || {
    echo "WARNING: Dev server health check failed, but continuing..."
}

# Run E2E tests (split 4 of 5)
echo "Running E2E tests (split 4 of 5)..."
gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1

# Capture test exit code
TEST_EXIT_CODE=$?

# Clean up
echo "Cleaning up..."
kill $DEV_SERVER_PID 2>/dev/null || true
docker stop inngest-test-postgres 2>/dev/null || true
docker rm inngest-test-postgres 2>/dev/null || true

# Exit with test result
exit $TEST_EXIT_CODE