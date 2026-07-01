#!/bin/bash
set -e

# Run Go tests with race detector and coverage
export DRIVER=sqlite
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...