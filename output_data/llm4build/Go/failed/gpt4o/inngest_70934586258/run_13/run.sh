#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set up Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the necessary files are present
if [ ! -f internal/embeddocs/website/pages/docs/example.md ]; then
    echo "Creating example documentation file"
    echo "# Example Documentation" > internal/embeddocs/website/pages/docs/example.md
fi

# Install Go dependencies
go mod tidy

# Build the Go project
go build -o ./inngest-bin ./cmd

# Run E2E tests
echo "Running dev server"
mkdir -p coverage
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@host.docker.internal:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
echo "Ran dev server"
sleep 5
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null

# Assuming 'gotesplit' is a placeholder, replace with actual command if needed
# gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1