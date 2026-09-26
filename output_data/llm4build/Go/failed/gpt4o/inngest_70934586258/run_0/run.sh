#!/bin/bash

# Clone the repository and initialize submodules
git clone --recurse-submodules <repository-url> /app
cd /app

# Set up Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod download

# Start PostgreSQL
pg_ctlcluster 12 main start

# Build the Go project
go build -cover -o ./inngest-bin ./cmd

# Install Go tools
go install tool

# Run E2E tests
echo "Running dev server"
mkdir -p coverage
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@localhost:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
echo "Ran dev server"
sleep 5
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null

gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1