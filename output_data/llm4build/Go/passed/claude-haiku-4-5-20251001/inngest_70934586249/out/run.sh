#!/bin/bash
set -e

# Set environment variables for E2E tests
export GOCOVERDIR="coverage"
export API_URL="http://127.0.0.1:8288"
export INNGEST_EVENT_KEY="test"
export INNGEST_SIGNING_KEY="7468697320697320612074657374206b6579"
export INNGEST_DEV="http://127.0.0.1:8288"
export TEST_MODE="true"
export TEST_DATABASE="sqlite"
export EXPERIMENTAL_KEY_QUEUES_ENABLE="false"

# Ensure Go is in PATH
export PATH="/usr/local/go/bin:${PATH}"
export GOPATH="/home/testuser/go"
export PATH="${GOPATH}/bin:${PATH}"

echo "=== Building dev server with coverage ==="
go build -cover -o ./inngest-bin ./cmd

echo "=== Installing tools ==="
go install tool

echo "=== Running E2E tests ==="
echo "Starting dev server"
mkdir -p "$GOCOVERDIR"

# Start dev server in background
nohup ./inngest-bin dev --no-discovery 2> /tmp/dev-output.txt &
DEV_PID=$!
echo "Dev server started with PID $DEV_PID"

# Wait for server to be ready
sleep 5

# Health check
echo "Checking dev server health..."
if ! curl -f http://127.0.0.1:8288/dev > /dev/null 2>&1; then
    echo "WARNING: Dev server health check failed"
    cat /tmp/dev-output.txt || true
fi

# Run E2E tests with split (split 2 of 5)
echo "Running E2E tests (split 2 of 5)..."
gotesplit -total 5 -index 2 ./tests/golang -- -v -count=1

# Cleanup
kill $DEV_PID 2>/dev/null || true

echo "=== Converting coverage data ==="
ls -la "$GOCOVERDIR"
go tool covdata percent -i="$GOCOVERDIR" | tee coverage.txt

echo "=== E2E tests completed successfully ==="