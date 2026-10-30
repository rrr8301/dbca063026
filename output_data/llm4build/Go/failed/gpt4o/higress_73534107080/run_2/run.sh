#!/bin/bash

# Activate Go environment
export GOPATH=/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Initialize and update submodules
git submodule update --init --recursive

# Install project dependencies
go mod download

# Run prebuild script
/app/tools/hack/prebuild.sh

# Run tests
go version
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage