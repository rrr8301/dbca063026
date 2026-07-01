#!/usr/bin/env bash
set -euo pipefail

# Start Redis server in background
redis-server --daemonize yes
sleep 2

# Verify Redis is working
redis-cli ping

# Install gotestfmt
go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1

# Replace mutexes (deadlock detection)
go get github.com/sasha-s/go-deadlock
grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g' || true
grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g' || true
go install golang.org/x/tools/cmd/goimports@latest
grep -rl deadlock.Mutex ./pkg | xargs goimports -w || true
grep -rl deadlock.RWMutex ./pkg | xargs goimports -w || true
go mod tidy

# Mage Build
go install github.com/magefile/mage@latest
mage build

# Lint (golangci-lint)
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /root/go/bin v2.11.4
/root/go/bin/golangci-lint run --timeout=10m

# Test
set +e
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt
TEST_RESULT=$?
set -e

# Check if tests ran
if [ -f /tmp/gotest.log ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
