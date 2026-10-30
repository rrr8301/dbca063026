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

# Install Mage
echo "Installing Mage..."
go install github.com/magefile/mage@latest

# Install wire with Go 1.24 compatible version
echo "Installing wire..."
go install github.com/google/wire/cmd/wire@v0.6.0

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

# Note: staticcheck is skipped here as it will be run via GitHub Actions
# which has the correct Go version compatibility

# Run tests with race detector and JSON output
# Only test packages that have test files
echo "Running tests..."
TEST_FAILED=0

# Find all packages with test files
PACKAGES_WITH_TESTS=$(find ./pkg -name "*_test.go" -type f | xargs dirname | sort -u)

if [ -z "$PACKAGES_WITH_TESTS" ]; then
    echo "Warning: No test files found in ./pkg"
    TEST_FAILED=0
else
    # Run tests only on packages with test files
    MallocNanoZone=0 go test -race -json -v $PACKAGES_WITH_TESTS 2>&1 | tee /tmp/gotest.log | gotestfmt || TEST_FAILED=1
fi

# Also run tests on other directories that might have tests (but not ./pkg)
echo "Running integration and other tests..."
for dir in ./test ./cmd; do
    if [ -d "$dir" ]; then
        if find "$dir" -name "*_test.go" -type f | grep -q .; then
            echo "Testing $dir..."
            MallocNanoZone=0 go test -race -json -v "$dir/..." 2>&1 | tee -a /tmp/gotest.log | gotestfmt || TEST_FAILED=1
        fi
    fi
done

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Tests failed, but continuing for artifact collection..."
    exit 1
fi

exit 0