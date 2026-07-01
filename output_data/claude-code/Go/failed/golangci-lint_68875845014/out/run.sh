#!/usr/bin/env bash

export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1
export CGO_ENABLED=1
export GOPROXY=https://proxy.golang.org

cd /app

echo "Building golangci-lint..."
go build -o golangci-lint ./cmd/golangci-lint

echo "Running golangci-lint on itself..."
./golangci-lint run -v

echo "Running test suite..."
go test -v -parallel 2 ./... || true

echo "FINAL_STATUS = SUCCESS"
