#!/bin/bash
set -e

# Run Go tests with race detector and verbose output
go test -race -v ./...