#!/bin/bash
set -e

# Set Go environment variables
export GOPATH=/go
export PATH=/usr/local/go/bin:/go/bin:$PATH

# Navigate to working directory
cd $GOPATH/src/github.com/chi

# Download dependencies (including test dependencies)
go get -d -t ./...

# Run tests
make test