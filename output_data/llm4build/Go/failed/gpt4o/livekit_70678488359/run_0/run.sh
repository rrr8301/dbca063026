#!/bin/bash

set -euo pipefail

# Start Redis server
redis-server --daemonize yes

# Install Go dependencies
go mod tidy

# Replace mutexes
go get github.com/sasha-s/go-deadlock
grep -rl sync.Mutex ./pkg | xargs sed -i 's/sync\.Mutex/deadlock\.Mutex/g'
grep -rl sync.RWMutex ./pkg | xargs sed -i 's/sync\.RWMutex/deadlock\.RWMutex/g'
grep -rl deadlock.Mutex ./pkg | xargs goimports -w
grep -rl deadlock.RWMutex ./pkg | xargs goimports -w

# Build using Mage
mage build

# Run static check
staticcheck -checks '["all", "-ST1000", "-ST1003", "-ST1020", "-ST1021", "-ST1022", "-SA1019"]' ./...

# Run tests
MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt