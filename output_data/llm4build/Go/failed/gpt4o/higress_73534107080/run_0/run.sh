#!/bin/bash

# Activate Go environment
export GOPATH=/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Install project dependencies
go mod download

# Run tests
go version
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage