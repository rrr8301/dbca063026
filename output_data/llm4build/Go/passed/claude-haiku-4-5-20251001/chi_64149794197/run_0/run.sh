#!/bin/bash
set -e

# Set GOPATH
export GOPATH=/workspace
export PATH=$GOPATH/bin:$PATH

# Change to working directory
cd $GOPATH/src/github.com/go-chi/chi

# Fetch dependencies (download but don't install)
echo "Fetching dependencies..."
go get -d -t ./...

# Run tests
echo "Running tests..."
make test

echo "All tests completed successfully!"