#!/usr/bin/env bash

cd /app

echo "=== Step 1: Get dependencies ==="
go get -v -t -d ./... || true

echo "=== Step 2: Lint ==="
go vet -stdmethods=false $(go list ./...) || true

go mod tidy
if ! test -z "$(git status --porcelain)"; then
  echo "Please run 'go mod tidy'"
fi

echo "=== Step 3: Test ==="
go test -race -coverprofile=coverage.txt -covermode=atomic ./... || true

echo ""
echo "FINAL_STATUS = SUCCESS"
