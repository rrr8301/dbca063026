#!/bin/bash
set -e

# Install tools from the project
echo "Installing tools..."
go install ./cmd/...

# Install gotesplit for test splitting
echo "Installing gotesplit..."
go install github.com/inngest/gotesplit@latest

# Build dev server with coverage
echo "Building dev server..."
go build -cover -o ./inngest-bin ./cmd

echo "Setup complete. Ready for tests."

# Run E2E tests
echo "Running dev server..."
mkdir -p "$GOCOVERDIR"
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@localhost:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
DEV_PID=$!
echo "Dev server started with PID: $DEV_PID"

# Wait for dev server to be ready
sleep 5
if ! curl -f http://127.0.0.1:8288/dev > /dev/null 2>&1; then
    echo "ERROR: Dev server failed to start"
    kill $DEV_PID 2>/dev/null || true
    cat /tmp/dev-output.txt
    exit 1
fi

echo "Dev server is ready"

# Run the tests with gotesplit
echo "Running E2E tests..."
gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1

# Cleanup
kill $DEV_PID 2>/dev/null || true