#!/bin/bash
set -euo pipefail

# Install dependencies
go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1

# Replace mutexes
go get github.com/sasha-s/go-deadlock
grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g' || true
grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g' || true
go install golang.org/x/tools/cmd/goimports@latest
grep -rl deadlock.Mutex ./pkg | xargs goimports -w || true
grep -rl deadlock.RWMutex ./pkg | xargs goimports -w || true
go mod tidy

# Run tests
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt

# Check for test failures
if grep -q '"Action":"fail"' /tmp/gotest.log; then
    echo "Tests failed"
    exit 1
fi

echo "All tests passed"
exit 0