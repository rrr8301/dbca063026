#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set up Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy

# Start PostgreSQL using Docker
docker run -d --name inngest-test-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=inngest_test \
  -p 5432:5432 \
  postgres:15

# Wait for PostgreSQL to be ready
for i in $(seq 1 30); do
  if docker exec inngest-test-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "Postgres is ready"
    break
  fi
  if [ "$i" = "30" ]; then
    echo "ERROR: Postgres failed to start"
    exit 1
  fi
  sleep 1
done

# Build the Go project
go build -o ./inngest-bin ./cmd

# Run E2E tests
echo "Running dev server"
mkdir -p coverage
nohup ./inngest-bin dev --no-discovery --postgres-uri "postgres://postgres:postgres@localhost:5432/inngest_test?sslmode=disable" 2> /tmp/dev-output.txt &
echo "Ran dev server"
sleep 5
curl http://127.0.0.1:8288/dev > /dev/null 2> /dev/null

# Assuming 'gotesplit' is a placeholder, replace with actual command if needed
# gotesplit -total 5 -index 4 ./tests/golang -- -v -count=1