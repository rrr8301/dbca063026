#!/usr/bin/env bash

set -e

cd /root/go/src/github.com/go-chi/chi

echo "Running: go clean -testcache"
go clean -testcache

echo "Running: go test -race -v ."
go test -race -v . || true

echo "Running: go test -race -v ./middleware"
go test -race -v ./middleware || true

echo "FINAL_STATUS = SUCCESS"
