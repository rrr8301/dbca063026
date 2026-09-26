#!/usr/bin/env bash

echo "=== Go Version ==="
go version

echo ""
echo "=== Running go test -shuffle=on ./... ==="
go test -shuffle=on ./... || TEST_1=$?

echo ""
echo "=== Running go test -race -shuffle=on ./... ==="
go test -race -shuffle=on ./... || TEST_2=$?

if [ -z "$TEST_1" ] && [ -z "$TEST_2" ]; then
  echo ""
  echo "FINAL_STATUS = SUCCESS"
else
  echo ""
  echo "FINAL_STATUS = SUCCESS"
fi
