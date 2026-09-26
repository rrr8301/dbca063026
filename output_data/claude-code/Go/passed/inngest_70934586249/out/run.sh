#!/usr/bin/env bash

set -e

export PATH="$HOME/go/bin:$PATH"

echo "Building dev server..."
go build -cover -o ./inngest-bin ./cmd

echo "Installing tools..."
go install tool

echo "Verifying gotesplit is available..."
which gotesplit || echo "gotesplit not found in PATH"

echo "Setting up coverage directory..."
mkdir -p $GOCOVERDIR

echo "Starting dev server..."
nohup ./inngest-bin dev --no-discovery 2> /tmp/dev-output.txt &
echo "Dev server started"

sleep 5

echo "Checking if dev server is running..."
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null || true

echo "Running E2E tests (split 2 of 5)..."
gotesplit -total 5 -index 2 ./tests/golang -- -v -count=1

echo "Converting coverage for tooling..."
ls -la $GOCOVERDIR
go tool covdata percent -i=$GOCOVERDIR | tee coverage.txt

echo "FINAL_STATUS = SUCCESS"
