#!/usr/bin/env bash
set -e

cd /app

# Check go.mod was not modified
echo "=== Checking go.mod ==="
! go mod edit -json | jq -r .Go | grep -vPx '1.\d+' || {
  echo "^^^^ Incorrect go directive in go.mod: use only \`minor.major'."
  exit 1
}

# Build
echo "=== Building ==="
make && ./bin/akvorado version

# Tests
echo "=== Running Go tests ==="
make test-go

echo "FINAL_STATUS = SUCCESS"
