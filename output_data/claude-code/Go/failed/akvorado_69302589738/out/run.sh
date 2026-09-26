#!/usr/bin/env bash
set -e

cd /app

# Step 1: Check go.mod was not modified
echo "=== Checking go.mod ==="
! go mod edit -json | grep -o '"Go":"[^"]*"' | grep -vPx '"Go":"1\.\d+"' || {
    echo "^^^^ Incorrect go directive in go.mod: use only \`minor.major'."
    exit 1
}

# Step 2: Build
echo "=== Building ==="
make && ./bin/akvorado version

# Step 3: Tests
echo "=== Running tests ==="
make test-go || EXIT_CODE=$?

if [ -n "$EXIT_CODE" ]; then
    echo "FINAL_STATUS = FAIL"
    exit $EXIT_CODE
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
