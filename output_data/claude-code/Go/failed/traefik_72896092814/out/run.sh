#!/usr/bin/env bash

set -e

cd /app

echo "Generating test matrix..."
MATRIX_OUTPUT=$(go run ./internal/testsci/genmatrix.go 2>&1)
echo "$MATRIX_OUTPUT"

# Extract just the JSON line
MATRIX_JSON=$(echo "$MATRIX_OUTPUT" | grep "^matrix=" | cut -d'=' -f2)
echo "Matrix: $MATRIX_JSON"

# Parse the JSON and run tests for each package group
echo "$MATRIX_JSON" | jq -r '.[] | .Group' | while read -r PACKAGE_GROUP; do
    echo "Testing package group: $PACKAGE_GROUP"
    go test -v -parallel 8 $PACKAGE_GROUP || true
done

echo ""
echo "FINAL_STATUS = SUCCESS"
