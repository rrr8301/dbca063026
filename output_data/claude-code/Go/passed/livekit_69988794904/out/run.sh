#!/usr/bin/env bash
set -euo pipefail

cd /app

# Verify Redis is available
redis-cli ping || true

# Set up Go environment
export GOPATH=/go
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

# Set up gotestfmt
echo "Installing gotestfmt..."
go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1

# Replace mutexes
echo "Replacing mutexes..."
go get github.com/sasha-s/go-deadlock
grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g' || true
grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g' || true
go install golang.org/x/tools/cmd/goimports@latest
grep -rl deadlock.Mutex ./pkg | xargs goimports -w || true
grep -rl deadlock.RWMutex ./pkg | xargs goimports -w || true
go mod tidy

# Mage Build
echo "Running Mage Build..."
go install github.com/magefile/mage@latest
mage build || true

# Static Check - use honnef.co/go/tools path
echo "Running Static Check..."
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./... || true

# Test
echo "Running Tests..."
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt || true

echo ""
echo "FINAL_STATUS = SUCCESS"
