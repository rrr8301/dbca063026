#!/bin/bash

# Set Go environment variables
export CGO_ENABLED=1
export GOARCH=amd64

# Run tests
make test-race