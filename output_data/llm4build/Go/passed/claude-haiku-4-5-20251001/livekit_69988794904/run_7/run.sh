#!/bin/bash

set -euo pipefail

# Start Redis server
echo "Starting Redis server..."
redis-server --daemonize yes --port 6379

# Verify Redis is running
echo "Verifying Redis connectivity..."
redis-cli ping

# Navigate to workspace
cd /workspace

# Install Go tools
echo "Installing Go tools..."
go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1
go install golang.org/x/tools/cmd/goimports@v0.21.0

# Install staticcheck using a version compatible with Go 1.24
echo "Installing staticcheck..."
git config --global url."https://github.com/".insteadOf "git://github.com/" || true
go install honnef.co/go/tools/cmd/staticcheck@2024.1.1

# Install Mage
echo "Installing Mage..."
go install github.com/magefile/mage@latest

# Replace mutexes with deadlock detection
echo "Replacing mutexes with deadlock detection..."
go get github.com/sasha-s/go-deadlock

# Replace sync.Mutex with deadlock.Mutex
if grep -rl sync.Mutex ./pkg 2>/dev/null; then
    grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g'
fi

# Replace sync.RWMutex with deadlock.RWMutex
if grep -rl sync.RWMutex ./pkg 2>/dev/null; then
    grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g'
fi

# Replace imports
if grep -rl deadlock.Mutex ./pkg 2>/dev/null; then
    grep -rl deadlock.Mutex ./pkg | xargs sed -i 's/^import (/import (\n\t"github.com\/sasha-s\/go-deadlock"\n/' 2>/dev/null || true
fi

# Run goimports on modified files
if grep -rl deadlock.Mutex ./pkg 2>/dev/null; then
    grep -rl deadlock.Mutex ./pkg | xargs goimports -w
fi

if grep -rl deadlock.RWMutex ./pkg 2>/dev/null; then
    grep -rl deadlock.RWMutex ./pkg | xargs goimports -w
fi

# Tidy go modules
echo "Tidying Go modules..."
go mod tidy

# Build with Mage
echo "Building with Mage..."
mage build

# Run staticcheck
echo "Running staticcheck..."
staticcheck -checks "all,-ST1000,-ST1003,-ST1020,-ST1021,-ST1022,-SA1019" ./...

# Run tests with race detector and JSON output
echo "Running tests..."
TEST_FAILED=0
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt || TEST_FAILED=1

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Tests failed, but continuing for artifact collection..."
    exit 1
fi

exit 0