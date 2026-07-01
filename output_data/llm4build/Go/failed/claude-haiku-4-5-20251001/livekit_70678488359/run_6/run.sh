#!/bin/bash
set -euo pipefail

# Start Redis server in background
redis-server --daemonize yes --port 6379 --save ""

# Verify Redis connectivity (with retries)
for i in {1..10}; do
    if redis-cli ping > /dev/null 2>&1; then
        echo "Redis is ready"
        break
    fi
    echo "Waiting for Redis... ($i/10)"
    sleep 1
done

# Navigate to workspace
cd /workspace

# Replace mutexes with deadlock detection
go get github.com/sasha-s/go-deadlock
grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g' || true
grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g' || true
goimports -w $(grep -rl deadlock.Mutex ./pkg) || true
goimports -w $(grep -rl deadlock.RWMutex ./pkg) || true
go mod tidy

# Build with Mage
mage build

# Run Static Check
staticcheck -checks "all,-ST1000,-ST1003,-ST1020,-ST1021,-ST1022,-SA1019" ./...

# Run tests with race detector and JSON output
mkdir -p /tmp
set +e
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt
TEST_EXIT_CODE=$?
set -e

# Exit with test result code
exit $TEST_EXIT_CODE