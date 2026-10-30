#!/bin/bash

# Activate goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

# Install Go version from go.mod
GO_VERSION=$(grep '^go ' go.mod | awk '{print $2}')
goenv install -s "$GO_VERSION"
goenv global "$GO_VERSION"

# Ensure Go is available
export PATH="$GOENV_ROOT/shims:$PATH"

# Build dev server
go build -cover -o ./inngest-bin ./cmd

# Install tools
go install tool

# Run E2E tests
echo "Running dev server"
mkdir -p "$GOCOVERDIR"
nohup ./inngest-bin dev --no-discovery 2> /tmp/dev-output.txt &
echo "Ran dev server"
sleep 5
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null

gotesplit -total 5 -index 2 ./tests/golang -- -v -count=1

# Convert coverage for tooling
ls -la "$GOCOVERDIR"
go tool covdata percent -i="$GOCOVERDIR" | tee coverage.txt