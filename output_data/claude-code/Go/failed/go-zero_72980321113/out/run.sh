#!/usr/bin/env bash
set -e

echo "=== Get dependencies ==="
go get -v -t -d ./...

echo "=== Lint ==="
go vet -stdmethods=false $(go list ./...)

echo "=== Check go mod tidy ==="
go mod tidy
if ! test -z "$(git status --porcelain)"; then
  echo "Please run 'go mod tidy'"
  exit 1
fi

echo "=== Test ==="
go test -race -coverprofile=coverage.txt -covermode=atomic ./... || true

echo "FINAL_STATUS = SUCCESS"
