#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod download

# Run tests
go test -v -parallel 8 ./pkg/config/label ./pkg/config